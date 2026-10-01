"""Common schemas and generic pagination envelopes."""

import math
from typing import Generic, List, Optional, TypeVar
from pydantic import BaseModel, Field

T = TypeVar("T")


class PaginatedResponse(BaseModel, Generic[T]):
    """Generic envelope for paginated collections."""
    items: List[T] = Field(default_factory=list, description="List of items for current page")
    total: int = Field(default=0, description="Total count of matching records")
    page: int = Field(default=1, description="Current page number (1-indexed)")
    limit: int = Field(default=20, description="Number of items per page")
    total_pages: int = Field(default=0, description="Total number of pages")
    has_next: bool = Field(default=False, description="Whether another page exists")

    @classmethod
    def create(cls, items: List[T], total: int, page: int, limit: int) -> "PaginatedResponse[T]":
        """Factory method computing total_pages and has_next."""
        total_pages = math.ceil(total / limit) if limit > 0 else 0
        has_next = page < total_pages
        return cls(
            items=items,
            total=total,
            page=page,
            limit=limit,
            total_pages=total_pages,
            has_next=has_next,
        )


class MessageResponse(BaseModel):
    """Simple status/success message."""
    message: str
    detail: Optional[str] = None
