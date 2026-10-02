"""Community post, comments, likes, and saved post endpoints."""

import uuid
from typing import List, Optional
from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.dependencies.auth import get_current_user, get_optional_current_user
from app.models.post import PostType
from app.models.user import User
from app.schemas.comment import CommentCreate, CommentResponse
from app.schemas.common import MessageResponse, PaginatedResponse
from app.schemas.post import PostCreate, PostResponse, PostUpdate
from app.services import post_service

router = APIRouter(tags=["Community Posts"])


@router.get(
    "/posts",
    response_model=PaginatedResponse[PostResponse],
    summary="List and filter community feed posts",
    description="Retrieve real community posts with type filtering (knowledge, question, project, resource, discussion), tag filtering, keyword search, and pagination.",
)
def list_posts(
    type: Optional[PostType] = Query(None, description="Filter by post type"),
    tag: Optional[str] = Query(None, description="Filter by topic tag"),
    group_id: Optional[uuid.UUID] = Query(None, description="Filter by group ID"),
    search: Optional[str] = Query(None, description="Keyword search in title and content"),
    page: int = Query(1, ge=1, description="Page number"),
    limit: int = Query(20, ge=1, le=100, description="Items per page"),
    viewer: Optional[User] = Depends(get_optional_current_user),
    db: Session = Depends(get_db),
) -> PaginatedResponse[PostResponse]:
    """List community feed posts."""
    return post_service.list_posts(
        type_filter=type,
        tag_filter=tag,
        group_id=group_id,
        search=search,
        page=page,
        limit=limit,
        viewer=viewer,
        db=db,
    )


@router.get(
    "/posts/{post_id}",
    response_model=PostResponse,
    summary="Get single community post details with comments",
)
def get_post(
    post_id: uuid.UUID,
    viewer: Optional[User] = Depends(get_optional_current_user),
    db: Session = Depends(get_db),
) -> PostResponse:
    """Get single post."""
    return post_service.get_post_by_id(post_id, viewer, db)


@router.post(
    "/posts",
    response_model=PostResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Create a new community post",
    description="Publishes a new student post. Author identity is derived securely from the authenticated Firebase token.",
)
def create_post(
    payload: PostCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> PostResponse:
    """Create community post."""
    return post_service.create_post(current_user, payload, db)


@router.patch(
    "/posts/{post_id}",
    response_model=PostResponse,
    summary="Edit post (Author or Admin only)",
)
def update_post(
    post_id: uuid.UUID,
    payload: PostUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> PostResponse:
    """Update post."""
    return post_service.update_post(post_id, current_user, payload, db)


@router.delete(
    "/posts/{post_id}",
    response_model=MessageResponse,
    summary="Delete post (Author or Admin only)",
)
def delete_post(
    post_id: uuid.UUID,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> MessageResponse:
    """Delete post."""
    post_service.delete_post(post_id, current_user, db)
    return MessageResponse(message="Post successfully deleted.")


@router.post(
    "/posts/{post_id}/like",
    summary="Toggle like on a post",
    description="Toggles like for the authenticated user and returns updated like count.",
)
def toggle_like_post(
    post_id: uuid.UUID,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Toggle post like."""
    result = post_service.toggle_like_post(current_user, post_id, db)
    return {"post_id": str(post_id), **result}


@router.delete(
    "/posts/{post_id}/like",
    summary="Unlike post",
)
def unlike_post(
    post_id: uuid.UUID,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Idempotently unlike post."""
    result = post_service.unlike_post(current_user, post_id, db)
    return {"post_id": str(post_id), **result}


@router.post(
    "/posts/{post_id}/save",
    summary="Toggle save post bookmark",
)
def toggle_save_post(
    post_id: uuid.UUID,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Toggle save post."""
    is_saved = post_service.toggle_save_post(current_user, post_id, db)
    return {"post_id": str(post_id), "is_saved": is_saved}


@router.delete(
    "/posts/{post_id}/save",
    summary="Unsave post",
)
def unsave_post(
    post_id: uuid.UUID,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Idempotently unsave post."""
    is_saved = post_service.unsave_post(current_user, post_id, db)
    return {"post_id": str(post_id), "is_saved": is_saved}


@router.get(
    "/me/saved-posts",
    response_model=PaginatedResponse[PostResponse],
    summary="List current user's saved posts",
)
@router.get(
    "/users/me/saved-posts",
    response_model=PaginatedResponse[PostResponse],
    include_in_schema=False,
)
def list_my_saved_posts(
    page: int = Query(1, ge=1),
    limit: int = Query(20, ge=1, le=100),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> PaginatedResponse[PostResponse]:
    """List saved posts."""
    return post_service.list_saved_posts(current_user, page, limit, db)


@router.post(
    "/posts/{post_id}/comments",
    response_model=CommentResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Add a comment to a post",
)
def add_comment(
    post_id: uuid.UUID,
    payload: CommentCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> CommentResponse:
    """Add comment to post."""
    return post_service.add_comment(current_user, post_id, payload, db)


@router.delete(
    "/comments/{comment_id}",
    response_model=MessageResponse,
    summary="Delete comment (Author or Admin only)",
)
def delete_comment(
    comment_id: uuid.UUID,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> MessageResponse:
    """Delete comment."""
    post_service.delete_comment(comment_id, current_user, db)
    return MessageResponse(message="Comment successfully deleted.")
