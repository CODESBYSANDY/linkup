"""Tests for Opportunity CRUD, filtering, search, and bookmarking."""

from datetime import datetime, timedelta, timezone
from fastapi.testclient import TestClient
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.category import Category
from app.models.user import User


def test_list_categories(client: TestClient):
    """Verify static reference categories are returned."""
    response = client.get("/api/v1/categories")
    assert response.status_code == 200
    categories = response.json()
    assert len(categories) >= 5
    slugs = [c["slug"] for c in categories]
    assert "hackathons" in slugs
    assert "internships" in slugs


def test_create_and_get_opportunity(
    client: TestClient, admin_user: User, admin_headers: dict, user_headers: dict, db_session: Session
):
    """Verify admin can create opportunity and students can read it."""
    # Get a category ID
    category = db_session.execute(select(Category)).scalars().first()
    deadline = (datetime.now(timezone.utc) + timedelta(days=14)).isoformat()

    payload = {
        "title": "Smart India Hackathon 2026",
        "description": "National level student innovation sprint",
        "organization": "Ministry of Education",
        "category_id": str(category.id),
        "domain": "Software Development",
        "location": "New Delhi, India",
        "mode": "OFFLINE",
        "eligibility": "Undergraduate students",
        "skills": ["Python", "Flutter", "PostgreSQL"],
        "prize": "₹1,00,000",
        "deadline": deadline,
        "registration_url": "https://sih.gov.in",
        "is_featured": True,
    }

    # 1. Create opportunity via admin
    create_res = client.post("/api/v1/opportunities", json=payload, headers=admin_headers)
    assert create_res.status_code == 201
    opp_data = create_res.json()
    opp_id = opp_data["id"]
    assert opp_data["title"] == "Smart India Hackathon 2026"
    assert opp_data["is_featured"] is True

    # 2. Query opportunity list as normal student
    list_res = client.get("/api/v1/opportunities?domain=Software", headers=user_headers)
    assert list_res.status_code == 200
    list_data = list_res.json()
    assert list_data["total"] >= 1
    assert any(item["id"] == opp_id for item in list_data["items"])

    # 3. Toggle save opportunity
    save_res = client.post(f"/api/v1/opportunities/{opp_id}/save", headers=user_headers)
    assert save_res.status_code == 200
    assert save_res.json()["is_saved"] is True

    # 4. Check saved opportunities list
    saved_list_res = client.get("/api/v1/me/saved-opportunities", headers=user_headers)
    assert saved_list_res.status_code == 200
    assert any(item["id"] == opp_id for item in saved_list_res.json()["items"])

    # 5. Unsave opportunity (Idempotency verification: calling DELETE multiple times never re-saves)
    unsave_res = client.delete(f"/api/v1/opportunities/{opp_id}/save", headers=user_headers)
    assert unsave_res.status_code == 200
    assert unsave_res.json()["is_saved"] is False

    # Second DELETE call must remain False (strict idempotency)
    unsave_repeat_res = client.delete(f"/api/v1/opportunities/{opp_id}/save", headers=user_headers)
    assert unsave_repeat_res.status_code == 200
    assert unsave_repeat_res.json()["is_saved"] is False
