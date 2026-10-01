"""Post Pydantic schemas."""

from datetime import datetime
from typing import List, Optional
from pydantic import BaseModel, ConfigDict, Field
from app.models.post import PostType
from app.schemas.comment import CommentResponse


class PostCreate(BaseModel):
    """Payload to create a new community post."""
    type: PostType = PostType.discussion
    title: str = Field(min_length=1, max_length=255)
    content: str = Field(min_length=1)
    tags: List[str] = Field(default_factory=list)
    group_id: Optional[str] = None
    external_url: Optional[str] = None
    image_url: Optional[str] = None


class PostUpdate(BaseModel):
    """Payload to update an existing community post."""
    title: Optional[str] = Field(None, min_length=1, max_length=255)
    content: Optional[str] = None
    type: Optional[PostType] = None
    tags: Optional[List[str]] = None
    group_id: Optional[str] = None
    external_url: Optional[str] = None
    image_url: Optional[str] = None


class PostResponse(BaseModel):
    """Community post response model matching Flutter expectations."""
    model_config = ConfigDict(from_attributes=True)

    id: str
    author_id: str
    author_name: str
    author_role: str = "Student"
    author_year: str = "Year 1"
    author_avatar: str = "SU"
    type: PostType
    title: str
    content: str
    tags: List[str] = Field(default_factory=list)
    liked_user_ids: List[str] = Field(default_factory=list)
    comments: List[CommentResponse] = Field(default_factory=list)
    likes_count: int = 0
    comments_count: int = 0
    is_liked_by_current_user: bool = False
    is_saved_by_current_user: bool = False
    time_ago: str = ""
    group_id: Optional[str] = None
    group_name: Optional[str] = None
    external_url: Optional[str] = None
    image_url: Optional[str] = None
    created_at: datetime
