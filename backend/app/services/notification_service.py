"""Notification service."""

import uuid
from datetime import datetime, timezone
from typing import Any, Dict, Optional
from fastapi import HTTPException, status
from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.models.notification import Notification, NotificationType
from app.models.user import User
from app.schemas.common import PaginatedResponse
from app.schemas.notification import NotificationResponse
from app.services.post_service import _format_time_ago


def list_notifications(
    user: User, page: int, limit: int, db: Session
) -> PaginatedResponse[NotificationResponse]:
    """List paginated notifications for the authenticated user."""
    stmt = (
        select(Notification)
        .where(Notification.user_id == user.id)
        .order_by(Notification.created_at.desc())
    )

    total = db.scalar(select(func.count()).select_from(stmt.subquery())) or 0
    stmt = stmt.offset((page - 1) * limit).limit(limit)
    notifications = db.execute(stmt).scalars().all()

    items = [
        NotificationResponse(
            id=str(n.id),
            title=n.title,
            message=n.message,
            type=n.type,
            is_read=n.is_read,
            data=n.data,
            created_at=n.created_at,
            time_ago=_format_time_ago(n.created_at),
        )
        for n in notifications
    ]
    return PaginatedResponse.create(items=items, total=total, page=page, limit=limit)


def mark_as_read(user: User, notification_id: uuid.UUID, db: Session) -> None:
    """Mark a single notification as read."""
    notif = db.get(Notification, notification_id)
    if not notif or notif.user_id != user.id:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Notification not found.",
        )
    notif.is_read = True
    db.commit()


def mark_all_as_read(user: User, db: Session) -> int:
    """Mark all unread notifications for the user as read."""
    unread = (
        db.execute(
            select(Notification).where(
                Notification.user_id == user.id, Notification.is_read == False
            )
        )
        .scalars()
        .all()
    )
    count = len(unread)
    for n in unread:
        n.is_read = True
    db.commit()
    return count


def create_notification(
    user_id: uuid.UUID,
    notif_type: NotificationType,
    title: str,
    message: str,
    data: Optional[Dict[str, Any]],
    db: Session,
) -> Notification:
    """Create a persistent notification for a student."""
    notif = Notification(
        user_id=user_id,
        type=notif_type,
        title=title,
        message=message,
        data=data,
        is_read=False,
    )
    db.add(notif)
    db.commit()
    db.refresh(notif)
    return notif
