"""Opportunity business logic service."""

import math
import uuid
from datetime import datetime, timezone
from typing import Optional
from fastapi import HTTPException, status
from sqlalchemy import func, or_, select
from sqlalchemy.orm import Session, joinedload

from app.models.category import Category
from app.models.opportunity import Opportunity, OpportunityMode, OpportunityStatus
from app.models.saved_opportunity import SavedOpportunity
from app.models.user import User
from app.schemas.common import PaginatedResponse
from app.schemas.opportunity import (
    OpportunityCreate,
    OpportunityResponse,
    OpportunityUpdate,
)


def _to_opportunity_response(
    opp: Opportunity, viewer: Optional[User], db: Session
) -> OpportunityResponse:
    """Format SQLAlchemy Opportunity model into API response model."""
    now = datetime.now(timezone.utc)
    deadline = opp.deadline
    if deadline.tzinfo is None:
        deadline = deadline.replace(tzinfo=timezone.utc)

    diff = (deadline - now).total_seconds()
    days_left = max(0, math.ceil(diff / 86400)) if diff > 0 else 0
    is_closing_soon = 0 < days_left <= 7

    is_saved = False
    if viewer:
        stmt = select(SavedOpportunity).where(
            SavedOpportunity.user_id == viewer.id,
            SavedOpportunity.opportunity_id == opp.id,
        )
        is_saved = db.execute(stmt).scalar_one_or_none() is not None

    category_name = opp.category.name if opp.category else "Opportunity"

    return OpportunityResponse(
        id=str(opp.id),
        title=opp.title,
        organization=opp.organization,
        category=category_name,
        category_id=str(opp.category_id),
        domain=opp.domain,
        description=opp.description,
        eligibility=opp.eligibility,
        skills=opp.skills or [],
        location=opp.location,
        mode=opp.mode.value,
        prize=opp.prize,
        salary=opp.salary,
        deadline=opp.deadline,
        source=opp.source,
        source_id=opp.source_id,
        registration_url=opp.registration_url,
        image_url=opp.image_url,
        status=opp.status.value,
        is_featured=opp.is_featured,
        is_saved_by_current_user=is_saved,
        is_closing_soon=is_closing_soon,
        days_left=days_left,
        created_at=opp.created_at,
    )


def list_opportunities(
    category: Optional[str] = None,
    domain: Optional[str] = None,
    mode: Optional[str] = None,
    skills: Optional[str] = None,
    search: Optional[str] = None,
    featured: Optional[bool] = None,
    sort: str = "latest",
    page: int = 1,
    limit: int = 20,
    viewer: Optional[User] = None,
    db: Session = None,
) -> PaginatedResponse[OpportunityResponse]:
    """Retrieve filtered, searched, and sorted paginated opportunities."""
    stmt = (
        select(Opportunity)
        .options(joinedload(Opportunity.category))
        .where(Opportunity.is_active == True)
    )

    # By default, normal users only see ACTIVE opportunities
    stmt = stmt.where(Opportunity.status == OpportunityStatus.ACTIVE)

    # Category filter
    if category and category.lower() != "all":
        cat_slug = category.strip().lower()
        stmt = stmt.join(Opportunity.category).where(
            or_(
                func.lower(Category.slug) == cat_slug,
                func.lower(Category.name) == cat_slug,
                func.lower(Category.name).like(f"%{cat_slug}%"),
            )
        )

    # Domain filter
    if domain and domain.lower() != "all":
        stmt = stmt.where(func.lower(Opportunity.domain).like(f"%{domain.strip().lower()}%"))

    # Mode filter
    if mode and mode.lower() != "all":
        try:
            mode_enum = OpportunityMode(mode.upper())
            stmt = stmt.where(Opportunity.mode == mode_enum)
        except ValueError:
            pass

    # Skills filter
    if skills and skills.lower() != "all":
        skill_term = skills.strip().lower()
        # PostgreSQL ANY array check
        stmt = stmt.where(
            Opportunity.skills.any(skill_term)
            | func.lower(func.array_to_string(Opportunity.skills, ",")).like(f"%{skill_term}%")
        )

    # Featured filter
    if featured is not None:
        stmt = stmt.where(Opportunity.is_featured == featured)

    # Keyword Search
    if search:
        q = f"%{search.strip().lower()}%"
        stmt = stmt.where(
            or_(
                func.lower(Opportunity.title).like(q),
                func.lower(Opportunity.description).like(q),
                func.lower(Opportunity.organization).like(q),
                func.lower(Opportunity.domain).like(q),
                func.lower(func.array_to_string(Opportunity.skills, ",")).like(q),
            )
        )

    # Sorting
    if sort == "deadline_soon":
        stmt = stmt.order_by(Opportunity.deadline.asc())
    elif sort == "featured":
        stmt = stmt.order_by(Opportunity.is_featured.desc(), Opportunity.created_at.desc())
    else:  # Default: latest
        stmt = stmt.order_by(Opportunity.created_at.desc())

    # Count total
    total = db.scalar(select(func.count()).select_from(stmt.subquery())) or 0

    # Paginate
    stmt = stmt.offset((page - 1) * limit).limit(limit)
    opportunities = db.execute(stmt).scalars().all()

    items = [_to_opportunity_response(o, viewer, db) for o in opportunities]
    return PaginatedResponse.create(items=items, total=total, page=page, limit=limit)


def get_opportunity_by_id(
    opportunity_id: uuid.UUID, viewer: Optional[User], db: Session
) -> OpportunityResponse:
    """Retrieve a single opportunity by ID."""
    stmt = (
        select(Opportunity)
        .options(joinedload(Opportunity.category))
        .where(Opportunity.id == opportunity_id, Opportunity.is_active == True)
    )
    opp = db.execute(stmt).scalar_one_or_none()
    if not opp:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Opportunity not found.",
        )
    return _to_opportunity_response(opp, viewer, db)


def create_opportunity(
    payload: OpportunityCreate, db: Session
) -> OpportunityResponse:
    """Create a new opportunity (Admin)."""
    # Verify category exists
    cat_id = uuid.UUID(payload.category_id)
    category = db.get(Category, cat_id)
    if not category:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Category with ID {payload.category_id} does not exist.",
        )

    opp = Opportunity(
        title=payload.title,
        description=payload.description,
        organization=payload.organization,
        category_id=cat_id,
        domain=payload.domain,
        location=payload.location,
        mode=payload.mode,
        eligibility=payload.eligibility,
        skills=payload.skills,
        prize=payload.prize,
        salary=payload.salary,
        deadline=payload.deadline,
        source=payload.source,
        source_id=payload.source_id,
        registration_url=str(payload.registration_url),
        image_url=str(payload.image_url) if payload.image_url else None,
        is_featured=payload.is_featured,
        status=OpportunityStatus.ACTIVE,
        is_active=True,
    )
    db.add(opp)
    db.commit()
    db.refresh(opp)
    return _to_opportunity_response(opp, None, db)


def update_opportunity(
    opportunity_id: uuid.UUID, payload: OpportunityUpdate, db: Session
) -> OpportunityResponse:
    """Update existing opportunity fields (Admin)."""
    opp = db.get(Opportunity, opportunity_id)
    if not opp:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Opportunity not found.",
        )

    if payload.title is not None:
        opp.title = payload.title
    if payload.description is not None:
        opp.description = payload.description
    if payload.organization is not None:
        opp.organization = payload.organization
    if payload.category_id is not None:
        opp.category_id = uuid.UUID(payload.category_id)
    if payload.domain is not None:
        opp.domain = payload.domain
    if payload.location is not None:
        opp.location = payload.location
    if payload.mode is not None:
        opp.mode = payload.mode
    if payload.eligibility is not None:
        opp.eligibility = payload.eligibility
    if payload.skills is not None:
        opp.skills = payload.skills
    if payload.prize is not None:
        opp.prize = payload.prize
    if payload.salary is not None:
        opp.salary = payload.salary
    if payload.deadline is not None:
        opp.deadline = payload.deadline
    if payload.registration_url is not None:
        opp.registration_url = str(payload.registration_url)
    if payload.image_url is not None:
        opp.image_url = str(payload.image_url)
    if payload.status is not None:
        opp.status = payload.status
    if payload.is_featured is not None:
        opp.is_featured = payload.is_featured
    if payload.is_active is not None:
        opp.is_active = payload.is_active

    db.commit()
    db.refresh(opp)
    return _to_opportunity_response(opp, None, db)


def delete_opportunity(opportunity_id: uuid.UUID, db: Session) -> None:
    """Deactivate/delete an opportunity (Admin)."""
    opp = db.get(Opportunity, opportunity_id)
    if not opp:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Opportunity not found.",
        )
    opp.is_active = False
    opp.status = OpportunityStatus.REJECTED
    db.commit()


def toggle_save_opportunity(
    user: User, opportunity_id: uuid.UUID, db: Session
) -> bool:
    """Toggle bookmarking an opportunity for the current user."""
    opp = db.get(Opportunity, opportunity_id)
    if not opp or not opp.is_active:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Opportunity not found.",
        )

    stmt = select(SavedOpportunity).where(
        SavedOpportunity.user_id == user.id,
        SavedOpportunity.opportunity_id == opportunity_id,
    )
    saved = db.execute(stmt).scalar_one_or_none()

    if saved:
        db.delete(saved)
        db.commit()
        return False  # Now unsaved
    else:
        new_save = SavedOpportunity(user_id=user.id, opportunity_id=opportunity_id)
        db.add(new_save)
        db.commit()
        return True  # Now saved


def list_saved_opportunities(
    user: User, page: int, limit: int, db: Session
) -> PaginatedResponse[OpportunityResponse]:
    """List opportunities saved by the current user."""
    stmt = (
        select(Opportunity)
        .join(SavedOpportunity, Opportunity.id == SavedOpportunity.opportunity_id)
        .options(joinedload(Opportunity.category))
        .where(SavedOpportunity.user_id == user.id, Opportunity.is_active == True)
        .order_by(SavedOpportunity.created_at.desc())
    )

    total = db.scalar(select(func.count()).select_from(stmt.subquery())) or 0
    stmt = stmt.offset((page - 1) * limit).limit(limit)
    opportunities = db.execute(stmt).scalars().all()

    items = [_to_opportunity_response(o, user, db) for o in opportunities]
    return PaginatedResponse.create(items=items, total=total, page=page, limit=limit)
