"""User database model."""

import enum
import uuid
from datetime import datetime, timezone
from typing import TYPE_CHECKING, List, Optional
from sqlalchemy import Boolean, DateTime, Enum, Index, String, Uuid
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.core.database import Base

if TYPE_CHECKING:
    from app.models.profile import UserProfile
    from app.models.post import Post
    from app.models.comment import Comment
    from app.models.post_like import PostLike
    from app.models.saved_post import SavedPost
    from app.models.saved_opportunity import SavedOpportunity
    from app.models.connection import Connection
    from app.models.notification import Notification
    from app.models.device import Device


class UserRole(str, enum.Enum):
    """User authorization roles."""
    USER = "USER"
    ADMIN = "ADMIN"


class User(Base):
    """Core user account model tied to Firebase Authentication UID."""
    __tablename__ = "users"

    id: Mapped[uuid.UUID] = mapped_column(
        Uuid, primary_key=True, default=uuid.uuid4, index=True
    )
    firebase_uid: Mapped[str] = mapped_column(
        String(128), unique=True, nullable=False, index=True
    )
    email: Mapped[str] = mapped_column(
        String(255), unique=True, nullable=False, index=True
    )
    name: Mapped[str] = mapped_column(String(255), nullable=False)
    role: Mapped[UserRole] = mapped_column(
        Enum(UserRole, name="user_role_enum"), default=UserRole.USER, nullable=False
    )
    avatar_initials: Mapped[str] = mapped_column(String(10), default="SU", nullable=False)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
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
    profile: Mapped[Optional["UserProfile"]] = relationship(
        "UserProfile", back_populates="user", uselist=False, cascade="all, delete-orphan"
    )
    posts: Mapped[List["Post"]] = relationship("Post", back_populates="author")
    comments: Mapped[List["Comment"]] = relationship("Comment", back_populates="author")
    likes: Mapped[List["PostLike"]] = relationship("PostLike", back_populates="user")
    saved_posts: Mapped[List["SavedPost"]] = relationship("SavedPost", back_populates="user")
    saved_opportunities: Mapped[List["SavedOpportunity"]] = relationship(
        "SavedOpportunity", back_populates="user"
    )
    notifications: Mapped[List["Notification"]] = relationship(
        "Notification", back_populates="user", cascade="all, delete-orphan"
    )
    devices: Mapped[List["Device"]] = relationship(
        "Device", back_populates="user", cascade="all, delete-orphan"
    )

    __table_args__ = (
        Index("idx_users_role", "role"),
        Index("idx_users_is_active", "is_active"),
    )
