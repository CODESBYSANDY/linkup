"""Mentor and mentorship request models."""

import enum
import uuid
from datetime import datetime, timezone
from typing import TYPE_CHECKING, Any, Dict, List, Optional
from sqlalchemy import (
    ARRAY,
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
    from app.models.user import User


class MentorRequestStatus(str, enum.Enum):
    """Status of a student's request for mentorship."""
    PENDING = "PENDING"
    ACCEPTED = "ACCEPTED"
    REJECTED = "REJECTED"


class Mentor(Base):
    """Faculty, alumni, and industry mentor model."""
    __tablename__ = "mentors"

    id: Mapped[uuid.UUID] = mapped_column(
        Uuid, primary_key=True, default=uuid.uuid4, index=True
    )
    name: Mapped[str] = mapped_column(String(255), nullable=False)
    role: Mapped[str] = mapped_column(String(255), nullable=False)
    college: Mapped[str] = mapped_column(String(255), nullable=False)
    experience: Mapped[str] = mapped_column(String(100), default="1+ Years", nullable=False)
    badge: Mapped[str] = mapped_column(String(100), default="Mentor", nullable=False)
    about: Mapped[str] = mapped_column(Text, default="", nullable=False)
    skills: Mapped[List[str]] = mapped_column(
        ARRAY(String(100)), default=list, nullable=False
    )
    topics: Mapped[List[str]] = mapped_column(
        ARRAY(String(255)), default=list, nullable=False
    )
    sessions: Mapped[Optional[List[Dict[str, Any]]]] = mapped_column(
        JSONB, default=list, nullable=True
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        default=lambda: datetime.now(timezone.utc),
        nullable=False,
    )

    # Relationships
    requests: Mapped[List["MentorRequest"]] = relationship(
        "MentorRequest", back_populates="mentor", cascade="all, delete-orphan"
    )


class MentorRequest(Base):
    """Student mentorship request."""
    __tablename__ = "mentor_requests"

    id: Mapped[uuid.UUID] = mapped_column(
        Uuid, primary_key=True, default=uuid.uuid4, index=True
    )
    mentor_id: Mapped[uuid.UUID] = mapped_column(
        Uuid, ForeignKey("mentors.id", ondelete="CASCADE"), nullable=False, index=True
    )
    user_id: Mapped[uuid.UUID] = mapped_column(
        Uuid, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True
    )
    status: Mapped[MentorRequestStatus] = mapped_column(
        Enum(MentorRequestStatus, name="mentor_request_status_enum"),
        default=MentorRequestStatus.PENDING,
        nullable=False,
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        default=lambda: datetime.now(timezone.utc),
        nullable=False,
    )

    # Relationships
    mentor: Mapped["Mentor"] = relationship("Mentor", back_populates="requests")
    user: Mapped["User"] = relationship("User")

    __table_args__ = (
        UniqueConstraint("mentor_id", "user_id", name="uq_mentor_request_mentor_user"),
        Index("idx_mentor_requests_user", "user_id"),
    )
