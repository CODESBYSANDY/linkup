"""Users and profile endpoints."""

import uuid
from typing import Optional
from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.dependencies.auth import get_current_user, get_optional_current_user
from app.models.user import User
from app.schemas.common import PaginatedResponse
from app.schemas.user import UserProfileResponse, UserProfileUpdate, UserPublicResponse
from app.services import user_service

router = APIRouter(tags=["Users"])


@router.get(
    "/me",
    response_model=UserProfileResponse,
    summary="Get current authenticated user profile",
    description="Returns the full profile, saved opportunities, saved posts, and network status for the Firebase authenticated student.",
)
@router.get(
    "/users/me",
    response_model=UserProfileResponse,
    include_in_schema=False,
)
def get_me(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> UserProfileResponse:
    """Return authenticated user profile."""
    return user_service.get_user_profile(current_user, db)


@router.patch(
    "/me",
    response_model=UserProfileResponse,
    summary="Update current authenticated user profile",
    description="Updates student profile details such as name, bio, college, branch, year, avatar initials, skills, and interests.",
)
@router.patch(
    "/users/me",
    response_model=UserProfileResponse,
    include_in_schema=False,
)
def update_me(
    payload: UserProfileUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> UserProfileResponse:
    """Update authenticated user profile."""
    return user_service.update_user_profile(current_user, payload, db)


@router.get(
    "/users",
    response_model=PaginatedResponse[UserPublicResponse],
    summary="List and search student peers / members",
    description="Returns paginated list of real registered students with optional keyword search.",
)
def list_users(
    query: str = Query("", description="Search term for name, college, branch, bio"),
    page: int = Query(1, ge=1, description="Page number"),
    limit: int = Query(20, ge=1, le=100, description="Items per page"),
    viewer: Optional[User] = Depends(get_optional_current_user),
    db: Session = Depends(get_db),
) -> PaginatedResponse[UserPublicResponse]:
    """List student members."""
    return user_service.list_users(viewer, query, page, limit, db)


@router.get(
    "/users/{user_id}",
    response_model=UserPublicResponse,
    summary="Get public profile of another student",
    description="Returns public details, skills, and connection status for a specific student ID.",
)
def get_user_public_profile(
    user_id: uuid.UUID,
    viewer: Optional[User] = Depends(get_optional_current_user),
    db: Session = Depends(get_db),
) -> UserPublicResponse:
    """Retrieve public profile."""
    return user_service.get_public_profile(user_id, viewer, db)
