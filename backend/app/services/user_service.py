"""User and profile business logic service."""

import uuid
from typing import Optional
from fastapi import HTTPException, status
from sqlalchemy import func, or_, select
from sqlalchemy.orm import Session

from app.models.connection import Connection, ConnectionStatus
from app.models.group import GroupMembership
from app.models.mentor import MentorRequest
from app.models.profile import UserProfile
from app.models.saved_opportunity import SavedOpportunity
from app.models.saved_post import SavedPost
from app.models.user import User
from app.schemas.common import PaginatedResponse
from app.schemas.user import UserProfileResponse, UserProfileUpdate, UserPublicResponse


def get_user_profile(user: User, db: Session) -> UserProfileResponse:
    """Retrieve full profile for the authenticated user, assembling IDs of saved/joined items."""
    profile = user.profile
    if not profile:
        profile = UserProfile(user_id=user.id)
        db.add(profile)
        db.commit()
        db.refresh(profile)

    # Gather relational ID lists
    saved_opp_ids = [
        str(row[0])
        for row in db.execute(
            select(SavedOpportunity.opportunity_id).where(SavedOpportunity.user_id == user.id)
        ).all()
    ]
    saved_post_ids = [
        str(row[0])
        for row in db.execute(
            select(SavedPost.post_id).where(SavedPost.user_id == user.id)
        ).all()
    ]
    joined_group_ids = [
        str(row[0])
        for row in db.execute(
            select(GroupMembership.group_id).where(GroupMembership.user_id == user.id)
        ).all()
    ]
    connected_user_ids = [
        str(row[0])
        for row in db.execute(
            select(Connection.receiver_id).where(
                Connection.requester_id == user.id,
                Connection.status == ConnectionStatus.ACCEPTED,
            )
        ).all()
    ]
    pending_connection_ids = [
        str(row[0])
        for row in db.execute(
            select(Connection.receiver_id).where(
                Connection.requester_id == user.id,
                Connection.status == ConnectionStatus.PENDING,
            )
        ).all()
    ]
    requested_mentor_ids = [
        str(row[0])
        for row in db.execute(
            select(MentorRequest.mentor_id).where(MentorRequest.user_id == user.id)
        ).all()
    ]

    return UserProfileResponse(
        id=str(user.id),
        name=user.name,
        email=user.email,
        role=user.role,
        college=profile.college,
        branch=profile.branch,
        year=profile.year,
        bio=profile.bio,
        avatar_initials=user.avatar_initials,
        avatar_url=profile.avatar_url,
        skills=profile.skills or [],
        interests=profile.interests or [],
        saved_opportunity_ids=saved_opp_ids,
        saved_post_ids=saved_post_ids,
        joined_group_ids=joined_group_ids,
        connected_user_ids=connected_user_ids,
        pending_connection_ids=pending_connection_ids,
        requested_mentor_ids=requested_mentor_ids,
        is_onboarded=profile.is_onboarded,
        created_at=user.created_at,
    )


def update_user_profile(
    user: User, update_data: UserProfileUpdate, db: Session
) -> UserProfileResponse:
    """Update current user's profile information."""
    profile = user.profile
    if not profile:
        profile = UserProfile(user_id=user.id)
        db.add(profile)
        db.flush()

    if update_data.name is not None:
        user.name = update_data.name.strip()
        # Compute initials
        parts = [p[0].upper() for p in user.name.split() if p]
        user.avatar_initials = "".join(parts)[:2] or "SU"

    if update_data.avatar_initials is not None:
        user.avatar_initials = update_data.avatar_initials.strip()

    if update_data.college is not None:
        profile.college = update_data.college.strip()
    if update_data.branch is not None:
        profile.branch = update_data.branch.strip()
    if update_data.year is not None:
        profile.year = update_data.year.strip()
    if update_data.bio is not None:
        profile.bio = update_data.bio.strip()
    if update_data.skills is not None:
        profile.skills = update_data.skills
    if update_data.interests is not None:
        profile.interests = update_data.interests
    if update_data.is_onboarded is not None:
        profile.is_onboarded = update_data.is_onboarded

    db.commit()
    db.refresh(user)
    return get_user_profile(user, db)


def get_public_profile(
    target_user_id: uuid.UUID, viewer: Optional[User], db: Session
) -> UserPublicResponse:
    """Retrieve public profile of another student."""
    stmt = select(User).where(User.id == target_user_id, User.is_active == True)
    target_user = db.execute(stmt).scalar_one_or_none()
    if not target_user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found.",
        )

    profile = target_user.profile
    connection_status = None
    if viewer and viewer.id != target_user.id:
        conn = db.execute(
            select(Connection).where(
                or_(
                    (Connection.requester_id == viewer.id) & (Connection.receiver_id == target_user.id),
                    (Connection.requester_id == target_user.id) & (Connection.receiver_id == viewer.id),
                )
            )
        ).scalar_one_or_none()
        if conn:
            connection_status = conn.status.value

    return UserPublicResponse(
        id=str(target_user.id),
        name=target_user.name,
        college=profile.college if profile else "",
        branch=profile.branch if profile else "",
        year=profile.year if profile else "Year 1",
        bio=profile.bio if profile else "",
        avatar_initials=target_user.avatar_initials,
        avatar_url=profile.avatar_url if profile else None,
        skills=profile.skills if profile else [],
        interests=profile.interests if profile else [],
        connection_status=connection_status,
        created_at=target_user.created_at,
    )


def list_users(
    viewer: Optional[User], query: str, page: int, limit: int, db: Session
) -> PaginatedResponse[UserPublicResponse]:
    """List registered users with optional search and pagination."""
    stmt = select(User).where(User.is_active == True)
    if viewer:
        stmt = stmt.where(User.id != viewer.id)

    if query:
        q = f"%{query.strip().lower()}%"
        stmt = stmt.outerjoin(UserProfile, User.id == UserProfile.user_id).where(
            or_(
                func.lower(User.name).like(q),
                func.lower(UserProfile.college).like(q),
                func.lower(UserProfile.branch).like(q),
                func.lower(UserProfile.bio).like(q),
            )
        )

    # Count total
    total = db.scalar(select(func.count()).select_from(stmt.subquery())) or 0

    # Paginate
    stmt = stmt.order_by(User.created_at.desc()).offset((page - 1) * limit).limit(limit)
    users = db.execute(stmt).scalars().all()

    items = [get_public_profile(u.id, viewer, db) for u in users]
    return PaginatedResponse.create(items=items, total=total, page=page, limit=limit)
