"""Automated n8n opportunity ingestion service."""

import uuid
from datetime import datetime, timezone
from typing import Optional
from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.core.logging import logger
from app.models.category import Category
from app.models.opportunity import Opportunity, OpportunityMode, OpportunityStatus
from app.schemas.ingest import IngestOpportunityPayload, IngestResponse


def _normalize_mode(raw_mode: str) -> OpportunityMode:
    """Normalize arbitrary mode strings into OpportunityMode enum."""
    val = raw_mode.strip().upper()
    if "HYBRID" in val:
        return OpportunityMode.HYBRID
    elif "OFFLINE" in val or "IN-PERSON" in val or "IN PERSON" in val:
        return OpportunityMode.OFFLINE
    return OpportunityMode.ONLINE


def _get_or_create_category(category_name_or_slug: str, db: Session) -> Category:
    """Find category by slug or name, or dynamically create if missing."""
    slug = category_name_or_slug.strip().lower().replace(" ", "-")
    name = category_name_or_slug.strip().title()

    stmt = select(Category).where(
        (func.lower(Category.slug) == slug) | (func.lower(Category.name) == name.lower())
    )
    category = db.execute(stmt).scalar_one_or_none()

    if not category:
        category = Category(
            name=name,
            slug=slug,
            description=f"Auto-generated category for {name}",
        )
        db.add(category)
        db.flush()
        logger.info("Auto-created new category during ingestion: %s (%s)", name, slug)

    return category


def ingest_opportunity(
    payload: IngestOpportunityPayload, db: Session
) -> IngestResponse:
    """Idempotently ingest an opportunity from n8n web scraper."""
    mode_enum = _normalize_mode(payload.mode)
    category = _get_or_create_category(payload.category, db)

    # Deduplication check on (source, source_id)
    existing_opp: Optional[Opportunity] = None
    if payload.source_id:
        stmt = select(Opportunity).where(
            Opportunity.source == payload.source,
            Opportunity.source_id == payload.source_id,
        )
        existing_opp = db.execute(stmt).scalar_one_or_none()

    if existing_opp:
        # Idempotent UPDATE
        existing_opp.title = payload.title
        existing_opp.description = payload.description
        existing_opp.organization = payload.organization
        existing_opp.category_id = category.id
        existing_opp.domain = payload.domain
        existing_opp.location = payload.location
        existing_opp.mode = mode_enum
        existing_opp.eligibility = payload.eligibility
        existing_opp.skills = payload.skills
        existing_opp.prize = payload.prize
        existing_opp.salary = payload.salary
        existing_opp.deadline = payload.deadline
        existing_opp.registration_url = str(payload.registration_url)
        if payload.image_url:
            existing_opp.image_url = str(payload.image_url)
        existing_opp.status = OpportunityStatus.ACTIVE
        existing_opp.is_active = True

        db.commit()
        db.refresh(existing_opp)
        logger.info(
            "Updated existing opportunity id=%s from source=%s external_id=%s",
            existing_opp.id,
            existing_opp.source,
            existing_opp.source_id,
        )
        return IngestResponse(
            status="updated",
            id=str(existing_opp.id),
            title=existing_opp.title,
            source=existing_opp.source,
            source_id=existing_opp.source_id,
            message="Opportunity successfully updated with latest source data.",
        )

    # INSERT new opportunity
    new_opp = Opportunity(
        title=payload.title,
        description=payload.description,
        organization=payload.organization,
        category_id=category.id,
        domain=payload.domain,
        location=payload.location,
        mode=mode_enum,
        eligibility=payload.eligibility,
        skills=payload.skills,
        prize=payload.prize,
        salary=payload.salary,
        deadline=payload.deadline,
        source=payload.source,
        source_id=payload.source_id,
        registration_url=str(payload.registration_url),
        image_url=str(payload.image_url) if payload.image_url else None,
        status=OpportunityStatus.ACTIVE,
        is_active=True,
    )
    db.add(new_opp)
    db.commit()
    db.refresh(new_opp)
    logger.info(
        "Created new opportunity id=%s from source=%s external_id=%s",
        new_opp.id,
        new_opp.source,
        new_opp.source_id,
    )
    return IngestResponse(
        status="created",
        id=str(new_opp.id),
        title=new_opp.title,
        source=new_opp.source,
        source_id=new_opp.source_id,
        message="New opportunity ingested and published successfully.",
    )
