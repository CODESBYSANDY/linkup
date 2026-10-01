"""Opportunity Pydantic schemas."""

from datetime import datetime, timezone
from typing import List, Optional
from pydantic import BaseModel, ConfigDict, Field, HttpUrl
from app.models.opportunity import OpportunityMode, OpportunityStatus


class OpportunityBase(BaseModel):
    """Base opportunity fields."""
    title: str = Field(min_length=1, max_length=255)
    description: str = Field(min_length=1)
    organization: str = Field(min_length=1, max_length=255)
    category_id: str
    domain: str = Field(default="General", max_length=100)
    location: str = Field(default="Online", max_length=255)
    mode: OpportunityMode = OpportunityMode.ONLINE
    eligibility: str = Field(default="All students with valid college ID", max_length=500)
    skills: List[str] = Field(default_factory=list)
    prize: Optional[str] = None
    salary: Optional[str] = None
    deadline: datetime
    registration_url: str = Field(max_length=1024)
    image_url: Optional[str] = None
    is_featured: bool = False


class OpportunityCreate(OpportunityBase):
    """Opportunity creation payload (Admin)."""
    source: str = Field(default="manual", max_length=100)
    source_id: Optional[str] = Field(None, max_length=255)


class OpportunityUpdate(BaseModel):
    """Opportunity partial update payload (Admin)."""
    title: Optional[str] = Field(None, min_length=1, max_length=255)
    description: Optional[str] = None
    organization: Optional[str] = None
    category_id: Optional[str] = None
    domain: Optional[str] = None
    location: Optional[str] = None
    mode: Optional[OpportunityMode] = None
    eligibility: Optional[str] = None
    skills: Optional[List[str]] = None
    prize: Optional[str] = None
    salary: Optional[str] = None
    deadline: Optional[datetime] = None
    registration_url: Optional[str] = None
    image_url: Optional[str] = None
    status: Optional[OpportunityStatus] = None
    is_featured: Optional[bool] = None
    is_active: Optional[bool] = None


class OpportunityResponse(BaseModel):
    """Opportunity API response model."""
    model_config = ConfigDict(from_attributes=True)

    id: str
    title: str
    organization: str
    category: str
    category_id: str
    domain: str
    description: str
    eligibility: str
    skills: List[str]
    location: str
    mode: str
    prize: Optional[str] = None
    salary: Optional[str] = None
    deadline: datetime
    source: str
    source_id: Optional[str] = None
    registration_url: str
    image_url: Optional[str] = None
    status: str
    is_featured: bool
    is_saved_by_current_user: bool = False
    is_closing_soon: bool = False
    days_left: int = 0
    created_at: datetime
