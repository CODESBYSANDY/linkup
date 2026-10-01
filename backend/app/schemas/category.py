"""Category Pydantic schemas."""

import uuid
from datetime import datetime
from typing import Optional
from pydantic import BaseModel, ConfigDict, Field


class CategoryBase(BaseModel):
    """Base category fields."""
    name: str = Field(min_length=1, max_length=100)
    slug: str = Field(min_length=1, max_length=100)
    description: Optional[str] = None


class CategoryCreate(CategoryBase):
    """Category creation payload."""
    pass


class CategoryResponse(CategoryBase):
    """Category response model."""
    model_config = ConfigDict(from_attributes=True)

    id: str
    created_at: datetime
