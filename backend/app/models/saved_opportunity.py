"""Saved opportunity model."""

import uuid
from datetime import datetime, timezone
from typing import TYPE_CHECKING
from sqlalchemy import DateTime, ForeignKey, Index, UniqueConstraint, Uuid
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.core.database import Base

if TYPE_CHECKING:
    from app.models.user import User
    from app.models.opportunity import Opportunity


class SavedOpportunity(Base):
    """User bookmark / saved opportunity."""
    __tablename__ = "saved_opportunities"

    id: Mapped[uuid.UUID] = mapped_column(
        Uuid, primary_key=True, default=uuid.uuid4, index=True
    )
    user_id: Mapped[uuid.UUID] = mapped_column(
        Uuid, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True
    )
    opportunity_id: Mapped[uuid.UUID] = mapped_column(
        Uuid, ForeignKey("opportunities.id", ondelete="CASCADE"), nullable=False, index=True
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        default=lambda: datetime.now(timezone.utc),
        nullable=False,
    )

    # Relationships
    user: Mapped["User"] = relationship("User", back_populates="saved_opportunities")
    opportunity: Mapped["Opportunity"] = relationship(
        "Opportunity", back_populates="saved_by"
    )

    __table_args__ = (
        UniqueConstraint(
            "user_id", "opportunity_id", name="uq_saved_opportunity_user_opportunity"
        ),
        Index("idx_saved_opps_user_id", "user_id"),
        Index("idx_saved_opps_opp_id", "opportunity_id"),
    )
