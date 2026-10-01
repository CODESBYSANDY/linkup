"""Connect, groups, and mentors endpoints."""

import uuid
from typing import List, Optional
from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.dependencies.auth import (
    get_current_user,
    get_optional_current_user,
    require_admin,
)
from app.models.connection import ConnectionStatus
from app.models.user import User
from app.schemas.connection import ConnectionResponse
from app.schemas.group import GroupCreate, GroupResponse
from app.schemas.mentor import MentorCreate, MentorResponse
from app.services import connect_service

router = APIRouter(tags=["Connect & Mentorship"])


@router.post(
    "/connections/{user_id}",
    summary="Toggle peer connection request",
    description="Sends, cancels, or accepts a peer connection with another student.",
)
def toggle_connect(
    user_id: uuid.UUID,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Toggle connection status."""
    new_state = connect_service.toggle_connect_user(current_user, user_id, db)
    return {"user_id": str(user_id), "status": new_state}


@router.get(
    "/connections",
    response_model=List[ConnectionResponse],
    summary="List current user's connections",
)
def list_connections(
    status: Optional[ConnectionStatus] = Query(None, description="Filter by status (PENDING, ACCEPTED)"),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> List[ConnectionResponse]:
    """List connections."""
    return connect_service.list_connections(current_user, status, db)


@router.get(
    "/groups",
    response_model=List[GroupResponse],
    summary="List student interest and practice groups",
)
def list_groups(
    viewer: Optional[User] = Depends(get_optional_current_user),
    db: Session = Depends(get_db),
) -> List[GroupResponse]:
    """List groups."""
    return connect_service.list_groups(viewer, db)


@router.post(
    "/groups/{group_id}/join",
    summary="Toggle join / leave group",
)
def toggle_join_group(
    group_id: uuid.UUID,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Toggle group membership."""
    is_joined = connect_service.toggle_join_group(current_user, group_id, db)
    return {"group_id": str(group_id), "is_joined": is_joined}


@router.get(
    "/mentors",
    response_model=List[MentorResponse],
    summary="List faculty, alumni, and industry mentors",
)
def list_mentors(
    viewer: Optional[User] = Depends(get_optional_current_user),
    db: Session = Depends(get_db),
) -> List[MentorResponse]:
    """List mentors."""
    return connect_service.list_mentors(viewer, db)


@router.post(
    "/mentors/{mentor_id}/request",
    summary="Toggle mentorship request",
)
def request_mentor(
    mentor_id: uuid.UUID,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Toggle mentorship request."""
    is_requested = connect_service.request_mentor(current_user, mentor_id, db)
    return {"mentor_id": str(mentor_id), "is_requested": is_requested}
