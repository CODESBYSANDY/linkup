"""Mentor and mentorship request schemas."""

from datetime import datetime
from typing import Any, Dict, List, Optional
from pydantic import BaseModel, ConfigDict, Field
from app.models.mentor import MentorRequestStatus


class LearningSessionSchema(BaseModel):
    """Structured learning session."""
    id: str
    title: str
    description: str
    duration: str


class MentorCreate(BaseModel):
    """Payload to register a mentor (Admin)."""
    name: str = Field(min_length=1, max_length=255)
    role: str = Field(min_length=1, max_length=255)
    college: str = Field(min_length=1, max_length=255)
    experience: str = Field(default="1+ Years", max_length=100)
    badge: str = Field(default="Mentor", max_length=100)
    about: str = Field(default="")
    skills: List[str] = Field(default_factory=list)
    topics: List[str] = Field(default_factory=list)
    sessions: Optional[List[Dict[str, Any]]] = Field(default_factory=list)


class MentorResponse(BaseModel):
    """Mentor response model matching Flutter expectations."""
    model_config = ConfigDict(from_attributes=True)

    id: str
    name: str
    role: str
    college: str
    experience: str
    badge: str
    about: str
    skills: List[str]
    topics: List[str]
    sessions: List[Dict[str, Any]] = Field(default_factory=list)
    is_requested_by_current_user: bool = False
    created_at: datetime


class MentorRequestResponse(BaseModel):
    """Mentorship request response."""
    model_config = ConfigDict(from_attributes=True)

    id: str
    mentor_id: str
    user_id: str
    status: MentorRequestStatus
    created_at: datetime
