"""Post, social feed, comment, and like business logic service."""

import math
import uuid
from datetime import datetime, timezone
from typing import Any, Dict, List, Optional
from fastapi import HTTPException, status
from sqlalchemy import func, or_, select
from sqlalchemy.orm import Session, joinedload

from app.models.comment import Comment
from app.models.group import Group
from app.models.post import Post, PostType
from app.models.post_like import PostLike
from app.models.saved_post import SavedPost
from app.models.user import User, UserRole
from app.schemas.comment import CommentCreate, CommentResponse
from app.schemas.common import PaginatedResponse
from app.schemas.post import PostCreate, PostResponse, PostUpdate


def _format_time_ago(dt: datetime) -> str:
    """Format datetime into human-friendly relative time string (e.g. 2h ago, 3d ago)."""
    now = datetime.now(timezone.utc)
    if dt.tzinfo is None:
        dt = dt.replace(tzinfo=timezone.utc)
    seconds = int((now - dt).total_seconds())

    if seconds < 60:
        return "just now"
    elif seconds < 3600:
        return f"{seconds // 60}m ago"
    elif seconds < 86400:
        return f"{seconds // 3600}h ago"
    elif seconds < 604800:
        return f"{seconds // 86400}d ago"
    else:
        return dt.strftime("%b %d, %Y")


def _to_comment_response(c: Comment) -> CommentResponse:
    """Format Comment model into CommentResponse schema."""
    author = c.author
    author_name = author.name if author else "Student"
    author_role = author.profile.branch if author and author.profile and author.profile.branch else "Student"
    author_avatar = author.avatar_initials if author else "SU"

    return CommentResponse(
        id=str(c.id),
        post_id=str(c.post_id),
        author_id=str(c.author_id),
        author_name=author_name,
        author_role=author_role,
        author_avatar=author_avatar,
        content=c.content,
        created_at=c.created_at,
        time_ago=_format_time_ago(c.created_at),
    )


def _to_post_response(
    post: Post, viewer: Optional[User], db: Session
) -> PostResponse:
    """Format Post model into PostResponse schema."""
    author = post.author
    author_name = author.name if author else "Student"
    author_role = (
        author.profile.branch if author and author.profile and author.profile.branch else "Student Developer"
    )
    author_year = author.profile.year if author and author.profile and author.profile.year else "Year 1"
    author_avatar = author.avatar_initials if author else "SU"

    # Get likes
    like_rows = db.execute(
        select(PostLike.user_id).where(PostLike.post_id == post.id)
    ).all()
    liked_user_ids = [str(r[0]) for r in like_rows]
    likes_count = len(liked_user_ids)
    is_liked = str(viewer.id) in liked_user_ids if viewer else False

    # Check is_saved
    is_saved = False
    if viewer:
        stmt = select(SavedPost).where(
            SavedPost.user_id == viewer.id,
            SavedPost.post_id == post.id,
        )
        is_saved = db.execute(stmt).scalar_one_or_none() is not None

    # Load active comments
    comments_stmt = (
        select(Comment)
        .options(joinedload(Comment.author).joinedload(User.profile))
        .where(Comment.post_id == post.id, Comment.is_deleted == False)
        .order_by(Comment.created_at.asc())
    )
    active_comments = db.execute(comments_stmt).scalars().all()
    comments_responses = [_to_comment_response(c) for c in active_comments]
    comments_count = len(comments_responses)

    # Optional group name
    group_name = None
    if post.group_id:
        group = db.get(Group, post.group_id)
        if group:
            group_name = group.name

    return PostResponse(
        id=str(post.id),
        author_id=str(post.author_id),
        author_name=author_name,
        author_role=author_role,
        author_year=author_year,
        author_avatar=author_avatar,
        type=post.type,
        title=post.title,
        content=post.content,
        tags=post.tags or [],
        liked_user_ids=liked_user_ids,
        comments=comments_responses,
        likes_count=likes_count,
        comments_count=comments_count,
        is_liked_by_current_user=is_liked,
        is_saved_by_current_user=is_saved,
        time_ago=_format_time_ago(post.created_at),
        group_id=str(post.group_id) if post.group_id else None,
        group_name=group_name,
        external_url=post.external_url,
        image_url=post.image_url,
        created_at=post.created_at,
    )


def list_posts(
    type_filter: Optional[PostType] = None,
    tag_filter: Optional[str] = None,
    group_id: Optional[uuid.UUID] = None,
    search: Optional[str] = None,
    page: int = 1,
    limit: int = 20,
    viewer: Optional[User] = None,
    db: Session = None,
) -> PaginatedResponse[PostResponse]:
    """Retrieve filtered, searched community feed posts."""
    stmt = (
        select(Post)
        .options(joinedload(Post.author).joinedload(User.profile))
        .where(Post.is_deleted == False)
    )

    if type_filter:
        stmt = stmt.where(Post.type == type_filter)

    if group_id:
        stmt = stmt.where(Post.group_id == group_id)

    if tag_filter and tag_filter.lower() != "all":
        tag_term = tag_filter.strip().lower()
        stmt = stmt.where(
            Post.tags.any(tag_term)
            | func.lower(func.array_to_string(Post.tags, ",")).like(f"%{tag_term}%")
        )

    if search:
        q = f"%{search.strip().lower()}%"
        stmt = stmt.where(
            or_(
                func.lower(Post.title).like(q),
                func.lower(Post.content).like(q),
                func.lower(func.array_to_string(Post.tags, ",")).like(q),
            )
        )

    total = db.scalar(select(func.count()).select_from(stmt.subquery())) or 0
    stmt = stmt.order_by(Post.created_at.desc()).offset((page - 1) * limit).limit(limit)
    posts = db.execute(stmt).scalars().all()

    items = [_to_post_response(p, viewer, db) for p in posts]
    return PaginatedResponse.create(items=items, total=total, page=page, limit=limit)


def get_post_by_id(
    post_id: uuid.UUID, viewer: Optional[User], db: Session
) -> PostResponse:
    """Retrieve a single post by ID."""
    stmt = (
        select(Post)
        .options(joinedload(Post.author).joinedload(User.profile))
        .where(Post.id == post_id, Post.is_deleted == False)
    )
    post = db.execute(stmt).scalar_one_or_none()
    if not post:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Post not found.",
        )
    return _to_post_response(post, viewer, db)


def create_post(
    author: User, payload: PostCreate, db: Session
) -> PostResponse:
    """Create a new post authored strictly by the authenticated user."""
    grp_id = uuid.UUID(payload.group_id) if payload.group_id else None
    if grp_id:
        group = db.get(Group, grp_id)
        if not group:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Specified group does not exist.",
            )

    post = Post(
        author_id=author.id,
        type=payload.type,
        title=payload.title,
        content=payload.content,
        tags=payload.tags,
        group_id=grp_id,
        external_url=payload.external_url,
        image_url=payload.image_url,
        is_deleted=False,
    )
    db.add(post)
    db.commit()
    db.refresh(post)
    return _to_post_response(post, author, db)


def update_post(
    post_id: uuid.UUID, user: User, payload: PostUpdate, db: Session
) -> PostResponse:
    """Update post with IDOR ownership validation."""
    post = db.get(Post, post_id)
    if not post or post.is_deleted:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Post not found.",
        )

    # Enforce authorization: only author or ADMIN can edit
    if post.author_id != user.id and user.role != UserRole.ADMIN:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You do not have permission to modify this post.",
        )

    if payload.title is not None:
        post.title = payload.title
    if payload.content is not None:
        post.content = payload.content
    if payload.type is not None:
        post.type = payload.type
    if payload.tags is not None:
        post.tags = payload.tags
    if payload.group_id is not None:
        post.group_id = uuid.UUID(payload.group_id) if payload.group_id else None
    if payload.external_url is not None:
        post.external_url = payload.external_url
    if payload.image_url is not None:
        post.image_url = payload.image_url

    db.commit()
    db.refresh(post)
    return _to_post_response(post, user, db)


def delete_post(
    post_id: uuid.UUID, user: User, db: Session
) -> None:
    """Soft delete post with IDOR ownership validation."""
    post = db.get(Post, post_id)
    if not post or post.is_deleted:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Post not found.",
        )

    # Enforce authorization: only author or ADMIN can delete
    if post.author_id != user.id and user.role != UserRole.ADMIN:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You do not have permission to delete this post.",
        )

    post.is_deleted = True
    db.commit()


def toggle_like_post(
    user: User, post_id: uuid.UUID, db: Session
) -> Dict[str, Any]:
    """Toggle liking a post for the authenticated user."""
    post = db.get(Post, post_id)
    if not post or post.is_deleted:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Post not found.",
        )

    stmt = select(PostLike).where(
        PostLike.post_id == post_id,
        PostLike.user_id == user.id,
    )
    like = db.execute(stmt).scalar_one_or_none()

    if like:
        db.delete(like)
        db.commit()
        is_liked = False
    else:
        new_like = PostLike(post_id=post_id, user_id=user.id)
        db.add(new_like)
        db.commit()
        is_liked = True

    count = db.scalar(
        select(func.count(PostLike.id)).where(PostLike.post_id == post_id)
    ) or 0
    return {"likes_count": count, "is_liked": is_liked}


def toggle_save_post(
    user: User, post_id: uuid.UUID, db: Session
) -> bool:
    """Toggle bookmarking a post for the authenticated user."""
    post = db.get(Post, post_id)
    if not post or post.is_deleted:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Post not found.",
        )

    stmt = select(SavedPost).where(
        SavedPost.post_id == post_id,
        SavedPost.user_id == user.id,
    )
    saved = db.execute(stmt).scalar_one_or_none()

    if saved:
        db.delete(saved)
        db.commit()
        return False  # Unsaved
    else:
        new_save = SavedPost(post_id=post_id, user_id=user.id)
        db.add(new_save)
        db.commit()
        return True  # Saved


def list_saved_posts(
    user: User, page: int, limit: int, db: Session
) -> PaginatedResponse[PostResponse]:
    """List posts saved by the authenticated user."""
    stmt = (
        select(Post)
        .join(SavedPost, Post.id == SavedPost.post_id)
        .options(joinedload(Post.author).joinedload(User.profile))
        .where(SavedPost.user_id == user.id, Post.is_deleted == False)
        .order_by(SavedPost.created_at.desc())
    )

    total = db.scalar(select(func.count()).select_from(stmt.subquery())) or 0
    stmt = stmt.offset((page - 1) * limit).limit(limit)
    posts = db.execute(stmt).scalars().all()

    items = [_to_post_response(p, user, db) for p in posts]
    return PaginatedResponse.create(items=items, total=total, page=page, limit=limit)


def add_comment(
    author: User, post_id: uuid.UUID, payload: CommentCreate, db: Session
) -> CommentResponse:
    """Add a new comment to a post."""
    post = db.get(Post, post_id)
    if not post or post.is_deleted:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Post not found.",
        )

    comment = Comment(
        post_id=post_id,
        author_id=author.id,
        content=payload.content.strip(),
        is_deleted=False,
    )
    db.add(comment)
    db.commit()
    db.refresh(comment)
    return _to_comment_response(comment)


def delete_comment(
    comment_id: uuid.UUID, user: User, db: Session
) -> None:
    """Soft delete a comment with ownership validation."""
    comment = db.get(Comment, comment_id)
    if not comment or comment.is_deleted:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Comment not found.",
        )

    if comment.author_id != user.id and user.role != UserRole.ADMIN:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You do not have permission to delete this comment.",
        )

    comment.is_deleted = True
    db.commit()
