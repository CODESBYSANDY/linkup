"""Opportunity and category endpoints."""

import uuid
from typing import List, Optional
from fastapi import APIRouter, Depends, Query, status
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.dependencies.auth import (
    get_current_user,
    get_optional_current_user,
    require_admin,
)
from app.models.category import Category
from app.models.user import User
from app.schemas.category import CategoryCreate, CategoryResponse
from app.schemas.common import MessageResponse, PaginatedResponse
from app.schemas.opportunity import (
    OpportunityCreate,
    OpportunityResponse,
    OpportunityUpdate,
)
from app.services import opportunity_service

router = APIRouter(tags=["Opportunities"])


@router.get(
    "/categories",
    response_model=List[CategoryResponse],
    summary="List opportunity categories",
    description="Returns standard opportunity categories (e.g., Hackathon, Internship, Job, Workshop, Competition).",
)
def list_categories(db: Session = Depends(get_db)) -> List[CategoryResponse]:
    """List all categories."""
    categories = db.execute(select(Category).order_by(Category.name.asc())).scalars().all()
    return [
        CategoryResponse(
            id=str(c.id),
            name=c.name,
            slug=c.slug,
            description=c.description,
            created_at=c.created_at,
        )
        for c in categories
    ]


@router.post(
    "/categories",
    response_model=CategoryResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Create opportunity category (Admin)",
)
def create_category(
    payload: CategoryCreate,
    admin_user: User = Depends(require_admin),
    db: Session = Depends(get_db),
) -> CategoryResponse:
    """Create a new category."""
    category = Category(
        name=payload.name.strip(),
        slug=payload.slug.strip().lower(),
        description=payload.description,
    )
    db.add(category)
    db.commit()
    db.refresh(category)
    return CategoryResponse(
        id=str(category.id),
        name=category.name,
        slug=category.slug,
        description=category.description,
        created_at=category.created_at,
    )


@router.get(
    "/opportunities",
    response_model=PaginatedResponse[OpportunityResponse],
    summary="List, search, and filter opportunities",
    description="Discover hackathons, internships, jobs, workshops, and competitions with rich filtering by category, domain, mode, skills, keyword search, and sorting.",
)
def list_opportunities(
    category: Optional[str] = Query(None, description="Category filter (e.g., Hackathon, Internship, Job)"),
    domain: Optional[str] = Query(None, description="Domain filter (e.g., Cybersecurity, AI / ML, Cloud)"),
    mode: Optional[str] = Query(None, description="Mode filter: ONLINE, OFFLINE, HYBRID"),
    skills: Optional[str] = Query(None, description="Filter by required skill (e.g., Python, Flutter)"),
    search: Optional[str] = Query(None, description="Full-text keyword search term"),
    featured: Optional[bool] = Query(None, description="Filter featured opportunities"),
    sort: str = Query("latest", description="Sort option: 'latest', 'deadline_soon', 'featured'"),
    page: int = Query(1, ge=1, description="Page number"),
    limit: int = Query(20, ge=1, le=100, description="Items per page"),
    viewer: Optional[User] = Depends(get_optional_current_user),
    db: Session = Depends(get_db),
) -> PaginatedResponse[OpportunityResponse]:
    """List opportunities with filters."""
    return opportunity_service.list_opportunities(
        category=category,
        domain=domain,
        mode=mode,
        skills=skills,
        search=search,
        featured=featured,
        sort=sort,
        page=page,
        limit=limit,
        viewer=viewer,
        db=db,
    )


@router.get(
    "/opportunities/{opportunity_id}",
    response_model=OpportunityResponse,
    summary="Get opportunity details",
    description="Returns detailed information, eligibility, skills, and registration link for an opportunity.",
)
def get_opportunity(
    opportunity_id: uuid.UUID,
    viewer: Optional[User] = Depends(get_optional_current_user),
    db: Session = Depends(get_db),
) -> OpportunityResponse:
    """Get single opportunity."""
    return opportunity_service.get_opportunity_by_id(opportunity_id, viewer, db)


@router.post(
    "/opportunities",
    response_model=OpportunityResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Create opportunity (Admin)",
)
def create_opportunity(
    payload: OpportunityCreate,
    admin_user: User = Depends(require_admin),
    db: Session = Depends(get_db),
) -> OpportunityResponse:
    """Create an opportunity."""
    return opportunity_service.create_opportunity(payload, db)


@router.patch(
    "/opportunities/{opportunity_id}",
    response_model=OpportunityResponse,
    summary="Update opportunity (Admin)",
)
def update_opportunity(
    opportunity_id: uuid.UUID,
    payload: OpportunityUpdate,
    admin_user: User = Depends(require_admin),
    db: Session = Depends(get_db),
) -> OpportunityResponse:
    """Update an opportunity."""
    return opportunity_service.update_opportunity(opportunity_id, payload, db)


@router.delete(
    "/opportunities/{opportunity_id}",
    response_model=MessageResponse,
    summary="Delete opportunity (Admin)",
)
def delete_opportunity(
    opportunity_id: uuid.UUID,
    admin_user: User = Depends(require_admin),
    db: Session = Depends(get_db),
) -> MessageResponse:
    """Delete an opportunity."""
    opportunity_service.delete_opportunity(opportunity_id, db)
    return MessageResponse(message="Opportunity successfully deleted.")


@router.post(
    "/opportunities/{opportunity_id}/save",
    summary="Toggle save / bookmark opportunity",
    description="Saves or removes an opportunity from the authenticated user's bookmark list.",
)
def toggle_save_opportunity(
    opportunity_id: uuid.UUID,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Toggle opportunity save status."""
    is_saved = opportunity_service.toggle_save_opportunity(current_user, opportunity_id, db)
    return {"opportunity_id": str(opportunity_id), "is_saved": is_saved}


@router.delete(
    "/opportunities/{opportunity_id}/save",
    summary="Unsave opportunity",
)
def unsave_opportunity(
    opportunity_id: uuid.UUID,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Unsave opportunity."""
    is_saved = opportunity_service.toggle_save_opportunity(current_user, opportunity_id, db)
    return {"opportunity_id": str(opportunity_id), "is_saved": is_saved}


@router.get(
    "/me/saved-opportunities",
    response_model=PaginatedResponse[OpportunityResponse],
    summary="List current user's saved opportunities",
)
@router.get(
    "/users/me/saved-opportunities",
    response_model=PaginatedResponse[OpportunityResponse],
    include_in_schema=False,
)
def list_my_saved_opportunities(
    page: int = Query(1, ge=1),
    limit: int = Query(20, ge=1, le=100),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> PaginatedResponse[OpportunityResponse]:
    """List authenticated user saved opportunities."""
    return opportunity_service.list_saved_opportunities(current_user, page, limit, db)
