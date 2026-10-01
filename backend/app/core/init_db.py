"""Database reference data seeder (Categories & System Reference Values only)."""

from sqlalchemy import select
from sqlalchemy.orm import Session
from app.core.logging import logger
from app.models.category import Category


STATIC_CATEGORIES = [
    {"name": "Hackathons", "slug": "hackathons", "description": "Student hackathons and rapid prototyping sprints."},
    {"name": "Internships", "slug": "internships", "description": "Summer and semester student internships."},
    {"name": "Jobs", "slug": "jobs", "description": "Entry-level full-time and graduate roles."},
    {"name": "Competitions", "slug": "competitions", "description": "Coding and algorithmic competitions."},
    {"name": "Workshops", "slug": "workshops", "description": "Hands-on tech workshops and masterclasses."},
    {"name": "Events", "slug": "events", "description": "Conferences, tech meetups, and symposiums."},
    {"name": "Scholarships", "slug": "scholarships", "description": "Academic grants and fellowship programs."},
]


def seed_static_reference_data(db: Session) -> None:
    """Seed static reference categories if they do not already exist."""
    try:
        for cat_data in STATIC_CATEGORIES:
            existing = db.execute(
                select(Category).where(Category.slug == cat_data["slug"])
            ).scalar_one_or_none()
            if not existing:
                category = Category(
                    name=cat_data["name"],
                    slug=cat_data["slug"],
                    description=cat_data["description"],
                )
                db.add(category)
        db.commit()
    except Exception as exc:
        db.rollback()
        logger.error("Failed to seed static reference categories: %s", exc)
