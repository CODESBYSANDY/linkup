"""Automated n8n opportunity ingestion schemas."""

from datetime import datetime
from typing import List, Optional
from pydantic import BaseModel, Field


class IngestOpportunityPayload(BaseModel):
    """Incoming payload from n8n web scraping and external collectors."""
    title: str = Field(min_length=1, max_length=255)
    description: str = Field(min_length=1)
    organization: str = Field(min_length=1, max_length=255)
    category: str = Field(min_length=1, max_length=100, description="Category slug or name (e.g., hackathon, internship, job, workshop)")
    domain: str = Field(default="General", max_length=100)
    location: str = Field(default="Online", max_length=255)
    mode: str = Field(default="online", description="Participation mode: online, offline, or hybrid")
    eligibility: str = Field(default="All students with valid ID", max_length=500)
    skills: List[str] = Field(default_factory=list)
    prize: Optional[str] = None
    salary: Optional[str] = None
    deadline: datetime
    source: str = Field(default="unstop", max_length=100)
    source_id: Optional[str] = Field(None, max_length=255, description="External platform ID for deduplication")
    registration_url: str = Field(max_length=1024)
    image_url: Optional[str] = None


class IngestResponse(BaseModel):
    """Response returned upon idempotent ingestion."""
    status: str = Field(description="'created' or 'updated'")
    id: str
    title: str
    source: str
    source_id: Optional[str] = None
    message: str
