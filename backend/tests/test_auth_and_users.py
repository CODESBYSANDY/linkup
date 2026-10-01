"""Tests for authentication and user profile management."""

from fastapi.testclient import TestClient
from app.models.user import User


def test_get_me_authenticated(client: TestClient, test_user: User, user_headers: dict):
    """Verify GET /api/v1/me returns real user profile for authenticated student."""
    response = client.get("/api/v1/me", headers=user_headers)
    assert response.status_code == 200
    data = response.json()
    assert data["id"] == str(test_user.id)
    assert data["email"] == test_user.email
    assert data["name"] == test_user.name
    assert data["college"] == "KPR Institute of Engineering and Technology"
    assert data["role"] == "USER"


def test_get_me_unauthenticated(client: TestClient):
    """Verify GET /api/v1/me returns 401 for unauthenticated requests."""
    response = client.get("/api/v1/me")
    assert response.status_code == 401


def test_update_profile(client: TestClient, test_user: User, user_headers: dict):
    """Verify PATCH /api/v1/me updates student profile details."""
    payload = {
        "name": "Updated Sandeep",
        "bio": "Specializing in Cybersecurity and Cloud Security",
        "skills": ["Python", "Wireshark", "FastAPI"],
        "year": "Year 4",
    }
    response = client.patch("/api/v1/me", json=payload, headers=user_headers)
    assert response.status_code == 200
    data = response.json()
    assert data["name"] == "Updated Sandeep"
    assert data["bio"] == "Specializing in Cybersecurity and Cloud Security"
    assert "Wireshark" in data["skills"]
    assert data["year"] == "Year 4"


def test_list_members_search(client: TestClient, test_user: User, test_user_2: User, user_headers: dict):
    """Verify GET /api/v1/users returns real registered users without fake data."""
    response = client.get("/api/v1/users", headers=user_headers)
    assert response.status_code == 200
    data = response.json()
    assert "items" in data
    assert data["total"] >= 1
    # Check that test_user_2 is listed
    names = [u["name"] for u in data["items"]]
    assert "Second Student" in names
