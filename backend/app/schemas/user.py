"""User and UserProfile Pydantic schemas."""

import uuid
from datetime import datetime
from typing import List, Optional
from pydantic import BaseModel, ConfigDict, EmailStr, Field
from app.models.user import UserRole


class UserBase(BaseModel):
    """Base user fields."""
    email: EmailStr
    name: str = Field(min_length=1, max_length=255)


class UserProfileUpdate(BaseModel):
    """Payload for updating the authenticated user's profile."""
    name: Optional[str] = Field(None, min_length=1, max_length=255)
    college: Optional[str] = Field(None, max_length=255)
    branch: Optional[str] = Field(None, max_length=255)
    year: Optional[str] = Field(None, max_length=50)
    bio: Optional[str] = Field(None, max_length=2000)
    avatar_initials: Optional[str] = Field(None, max_length=10)
    skills: Optional[List[str]] = Field(None)
    interests: Optional[List[str]] = Field(None)
    is_onboarded: Optional[bool] = None


class UserProfileResponse(BaseModel):
    """Full authenticated user profile response matching Flutter expectations."""
    model_config = ConfigDict(from_attributes=True)

    id: str
    name: str
    email: str
    role: UserRole
    college: str = ""
    branch: str = ""
    year: str = "Year 1"
    bio: str = ""
    avatar_initials: str = "SU"
    avatar_url: Optional[str] = None
    skills: List[str] = Field(default_factory=list)
    interests: List[str] = Field(default_factory=list)
    saved_opportunity_ids: List[str] = Field(default_factory=list)
    saved_post_ids: List[str] = Field(default_factory=list)
    joined_group_ids: List[str] = Field(default_factory=list)
    connected_user_ids: List[str] = Field(default_factory=list)
    pending_connection_ids: List[str] = Field(default_factory=list)
    requested_mentor_ids: List[str] = Field(default_factory=list)
    is_onboarded: bool = False
    created_at: datetime


class UserPublicResponse(BaseModel):
    """Publicly visible peer user profile."""
    model_config = ConfigDict(from_attributes=True)

    id: str
    name: str
    college: str = ""
    branch: str = ""
    year: str = "Year 1"
    bio: str = ""
    avatar_initials: str = "SU"
    avatar_url: Optional[str] = None
    skills: List[str] = Field(default_factory=list)
    interests: List[str] = Field(default_factory=list)
    connection_status: Optional[str] = None  # None, "PENDING", "ACCEPTED"
    created_at: datetime
