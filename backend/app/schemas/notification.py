"""Notification schemas."""

from datetime import datetime
from typing import Any, Dict, Optional
from pydantic import BaseModel, ConfigDict
from app.models.notification import NotificationType


class NotificationResponse(BaseModel):
    """Notification response model matching Flutter expectations."""
    model_config = ConfigDict(from_attributes=True)

    id: str
    title: str
    message: str
    type: NotificationType
    is_read: bool
    data: Optional[Dict[str, Any]] = None
    created_at: datetime
    time_ago: str = ""
