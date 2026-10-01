"""Opportunity database model."""

import enum
import uuid
from datetime import datetime, timezone
from typing import TYPE_CHECKING, Any, Dict, List, Optional
from sqlalchemy import (
    ARRAY,
    Boolean,
    DateTime,
    Enum,
    ForeignKey,
    Index,
    String,
    Text,
    UniqueConstraint,
    Uuid,
)
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.core.database import Base

if TYPE_CHECKING:
    from app.models.category import Category
    from app.models.saved_opportunity import SavedOpportunity


class OpportunityMode(str, enum.Enum):
    """Opportunity mode of participation."""
    ONLINE = "ONLINE"
    OFFLINE = "OFFLINE"
    HYBRID = "HYBRID"


class OpportunityStatus(str, enum.Enum):
    """Opportunity lifecycle state."""
    DRAFT = "DRAFT"
    PENDING_REVIEW = "PENDING_REVIEW"
    ACTIVE = "ACTIVE"
    EXPIRED = "EXPIRED"
    REJECTED = "REJECTED"


class Opportunity(Base):
    """Student opportunity model (hackathon, internship, job, contest, workshop)."""
    __tablename__ = "opportunities"

    id: Mapped[uuid.UUID] = mapped_column(
        Uuid, primary_key=True, default=uuid.uuid4, index=True
    )
    title: Mapped[str] = mapped_column(String(255), nullable=False)
    description: Mapped[str] = mapped_column(Text, nullable=False)
    organization: Mapped[str] = mapped_column(String(255), nullable=False)
    category_id: Mapped[uuid.UUID] = mapped_column(
        Uuid, ForeignKey("categories.id", ondelete="RESTRICT"), nullable=False, index=True
    )
    domain: Mapped[str] = mapped_column(String(100), default="General", nullable=False)
    location: Mapped[str] = mapped_column(String(255), default="Online", nullable=False)
    mode: Mapped[OpportunityMode] = mapped_column(
        Enum(OpportunityMode, name="opportunity_mode_enum"),
        default=OpportunityMode.ONLINE,
        nullable=False,
    )
    eligibility: Mapped[str] = mapped_column(
        String(500), default="All students with valid college ID", nullable=False
    )
    skills: Mapped[List[str]] = mapped_column(
        ARRAY(String(100)), default=list, nullable=False
    )
    prize: Mapped[Optional[str]] = mapped_column(String(255), nullable=True)
    salary: Mapped[Optional[str]] = mapped_column(String(255), nullable=True)
    deadline: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, index=True
    )
    source: Mapped[str] = mapped_column(
        String(100), default="manual", nullable=False, index=True
    )
    source_id: Mapped[Optional[str]] = mapped_column(
        String(255), nullable=True, index=True
    )
    registration_url: Mapped[str] = mapped_column(String(1024), nullable=False)
    image_url: Mapped[Optional[str]] = mapped_column(String(1024), nullable=True)
    status: Mapped[OpportunityStatus] = mapped_column(
        Enum(OpportunityStatus, name="opportunity_status_enum"),
        default=OpportunityStatus.ACTIVE,
        nullable=False,
        index=True,
    )
    is_featured: Mapped[bool] = mapped_column(
        Boolean, default=False, nullable=False, index=True
    )
    is_active: Mapped[bool] = mapped_column(
        Boolean, default=True, nullable=False, index=True
    )
    raw_source_payload: Mapped[Optional[Dict[str, Any]]] = mapped_column(
        JSONB, nullable=True
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        default=lambda: datetime.now(timezone.utc),
        nullable=False,
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
        nullable=False,
    )

    # Relationships
    category: Mapped["Category"] = relationship(
        "Category", back_populates="opportunities"
    )
    saved_by: Mapped[List["SavedOpportunity"]] = relationship(
        "SavedOpportunity", back_populates="opportunity", cascade="all, delete-orphan"
    )

    __table_args__ = (
        UniqueConstraint("source", "source_id", name="uq_opportunity_source_source_id"),
        Index("idx_opportunities_deadline_status", "deadline", "status"),
        Index("idx_opportunities_domain", "domain"),
        Index("idx_opportunities_mode", "mode"),
    )
