"""User profile database model."""

import uuid
from datetime import datetime, timezone
from typing import TYPE_CHECKING, List, Optional
from sqlalchemy import ARRAY, Boolean, DateTime, ForeignKey, Index, String, Text, Uuid
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.core.database import Base

if TYPE_CHECKING:
    from app.models.user import User


class UserProfile(Base):
    """Detailed student profile information."""
    __tablename__ = "user_profiles"

    id: Mapped[uuid.UUID] = mapped_column(
        Uuid, primary_key=True, default=uuid.uuid4, index=True
    )
    user_id: Mapped[uuid.UUID] = mapped_column(
        Uuid, ForeignKey("users.id", ondelete="CASCADE"), unique=True, nullable=False, index=True
    )
    college: Mapped[str] = mapped_column(String(255), default="", nullable=False)
    branch: Mapped[str] = mapped_column(String(255), default="", nullable=False)
    year: Mapped[str] = mapped_column(String(50), default="Year 1", nullable=False)
    bio: Mapped[str] = mapped_column(Text, default="", nullable=False)
    avatar_url: Mapped[Optional[str]] = mapped_column(String(1024), nullable=True)
    skills: Mapped[List[str]] = mapped_column(
        ARRAY(String(100)), default=list, nullable=False
    )
    interests: Mapped[List[str]] = mapped_column(
        ARRAY(String(100)), default=list, nullable=False
    )
    is_onboarded: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
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

    # Relationship
    user: Mapped["User"] = relationship("User", back_populates="profile")

    __table_args__ = (
        Index("idx_user_profiles_college", "college"),
        Index("idx_user_profiles_branch", "branch"),
    )
