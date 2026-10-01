"""Group and membership schemas."""

from datetime import datetime
from typing import Optional
from pydantic import BaseModel, ConfigDict, Field


class GroupCreate(BaseModel):
    """Payload to create a new group (Admin)."""
    name: str = Field(min_length=1, max_length=255)
    category: str = Field(min_length=1, max_length=100)
    description: str = Field(min_length=1)
    icon_name: str = Field(default="group", max_length=50)


class GroupResponse(BaseModel):
    """Group response model."""
    model_config = ConfigDict(from_attributes=True)

    id: str
    name: str
    category: str
    description: str
    members_count: int = 0
    icon_name: str = "group"
    is_joined_by_current_user: bool = False
    created_at: datetime
