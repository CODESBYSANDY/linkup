"""Notification endpoints."""

import uuid
from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.dependencies.auth import get_current_user
from app.models.user import User
from app.schemas.common import MessageResponse, PaginatedResponse
from app.schemas.notification import NotificationResponse
from app.services import notification_service

router = APIRouter(tags=["Notifications"])


@router.get(
    "/notifications",
    response_model=PaginatedResponse[NotificationResponse],
    summary="List notifications for the current user",
)
def list_notifications(
    page: int = Query(1, ge=1),
    limit: int = Query(20, ge=1, le=100),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> PaginatedResponse[NotificationResponse]:
    """List notifications."""
    return notification_service.list_notifications(current_user, page, limit, db)


@router.patch(
    "/notifications/{notification_id}/read",
    response_model=MessageResponse,
    summary="Mark single notification as read",
)
def mark_as_read(
    notification_id: uuid.UUID,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> MessageResponse:
    """Mark notification read."""
    notification_service.mark_as_read(current_user, notification_id, db)
    return MessageResponse(message="Notification marked as read.")


@router.post(
    "/notifications/read-all",
    response_model=MessageResponse,
    summary="Mark all unread notifications as read",
)
def mark_all_as_read(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> MessageResponse:
    """Mark all read."""
    count = notification_service.mark_all_as_read(current_user, db)
    return MessageResponse(message=f"Marked {count} notifications as read.")
