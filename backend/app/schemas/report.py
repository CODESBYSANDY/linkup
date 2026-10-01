"""Content report and moderation schemas."""

import uuid
from datetime import datetime
from typing import Optional
from pydantic import BaseModel, ConfigDict, Field
from app.models.report import ReportStatus


class ReportCreate(BaseModel):
    """Payload to file a content moderation report."""
    target_type: str = Field(pattern="^(post|comment|user)$", description="Type of target: post, comment, or user")
    target_id: str
    reason: str = Field(min_length=1, max_length=255)
    description: Optional[str] = Field(None, max_length=2000)


class ReportStatusUpdate(BaseModel):
    """Admin moderation action on a report."""
    status: ReportStatus


class ReportResponse(BaseModel):
    """Moderation report response model."""
    model_config = ConfigDict(from_attributes=True)

    id: str
    reporter_id: str
    target_type: str
    target_id: str
    reason: str
    description: Optional[str] = None
    status: ReportStatus
    created_at: datetime
