"""FastAPI authentication and role-based authorization dependencies."""

from typing import Optional
from fastapi import Depends, HTTPException, Security, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy.orm import Session
from sqlalchemy import select

from app.core.database import get_db
from app.core.firebase import verify_firebase_id_token
from app.models.user import User, UserRole
from app.models.profile import UserProfile
from app.core.logging import logger

security_bearer = HTTPBearer(auto_error=False)


def get_current_user(
    credentials: Optional[HTTPAuthorizationCredentials] = Security(security_bearer),
    db: Session = Depends(get_db),
) -> User:
    """Dependency that verifies Firebase ID token and loads/creates the PostgreSQL user."""
    if credentials is None or not credentials.credentials:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Authentication token is required.",
            headers={"WWW-Authenticate": "Bearer"},
        )

    token_payload = verify_firebase_id_token(credentials.credentials)
    firebase_uid = token_payload.get("uid")
    if not firebase_uid:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token payload is missing user identity.",
            headers={"WWW-Authenticate": "Bearer"},
        )

    # Query existing user from PostgreSQL
    stmt = select(User).where(User.firebase_uid == firebase_uid)
    user = db.execute(stmt).scalar_one_or_none()

    if user is None:
        # First-time user: automatically provision PostgreSQL record from Firebase claims
        email = token_payload.get("email") or f"{firebase_uid}@linkup.dev"
        name = token_payload.get("name") or email.split("@")[0].title()
        initials = "".join([part[0].upper() for part in name.split() if part])[:2] or "SU"

        # Check if email is already used by another account
        existing_email = db.execute(select(User).where(User.email == email)).scalar_one_or_none()
        if existing_email:
            # If same email under different UID, disambiguate
            email = f"{firebase_uid}_{email}"

        user = User(
            firebase_uid=firebase_uid,
            email=email,
            name=name,
            role=UserRole.USER,
            avatar_initials=initials,
            is_active=True,
        )
        db.add(user)
        db.flush()

        # Create linked user profile
        profile = UserProfile(
            user_id=user.id,
            college="",
            branch="",
            year="Year 1",
            bio="",
            skills=[],
            interests=[],
            is_onboarded=False,
        )
        db.add(profile)
        try:
            db.commit()
            db.refresh(user)
            logger.info("Provisioned new PostgreSQL user for Firebase UID %s", firebase_uid)
        except Exception:
            db.rollback()
            # Handle concurrent race condition: user was provisioned by another parallel thread
            user = db.execute(stmt).scalar_one_or_none()
            if user is None:
                raise HTTPException(
                    status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                    detail="Failed to initialize user session.",
                )

    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Your user account has been deactivated.",
        )

    return user


def get_optional_current_user(
    credentials: Optional[HTTPAuthorizationCredentials] = Security(security_bearer),
    db: Session = Depends(get_db),
) -> Optional[User]:
    """Dependency that returns current user if token is valid, or None if unauthenticated."""
    if credentials is None or not credentials.credentials:
        return None
    try:
        return get_current_user(credentials=credentials, db=db)
    except HTTPException:
        return None


def require_admin(
    current_user: User = Depends(get_current_user),
) -> User:
    """Dependency that enforces ADMIN role."""
    if current_user.role != UserRole.ADMIN:
        logger.warning(
            "Unauthorized admin access attempt by user %s (role: %s)",
            current_user.id,
            current_user.role,
        )
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Administrative privileges are required for this action.",
        )
    return current_user
