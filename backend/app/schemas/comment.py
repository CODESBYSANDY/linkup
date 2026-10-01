"""Comment Pydantic schemas."""

from datetime import datetime
from typing import Optional
from pydantic import BaseModel, ConfigDict, Field


class CommentCreate(BaseModel):
    """Payload to create a new comment."""
    content: str = Field(min_length=1, max_length=2000)


class CommentUpdate(BaseModel):
    """Payload to update an existing comment."""
    content: str = Field(min_length=1, max_length=2000)


class CommentResponse(BaseModel):
    """Comment response model."""
    model_config = ConfigDict(from_attributes=True)

    id: str
    post_id: str
    author_id: str
    author_name: str
    author_role: str = "Student"
    author_avatar: str = "SU"
    content: str
    created_at: datetime
    time_ago: str = ""
