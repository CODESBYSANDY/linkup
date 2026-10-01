"""Security and authorization tests."""

from fastapi.testclient import TestClient
from app.models.user import User


def test_normal_user_cannot_access_admin_endpoints(
    client: TestClient, user_headers: dict
):
    """Verify normal student (role USER) receives 403 Forbidden on admin routes."""
    # Try to view reports (Admin only)
    res_reports = client.get("/api/v1/admin/reports", headers=user_headers)
    assert res_reports.status_code == 403

    # Try to create category (Admin only)
    res_cat = client.post(
        "/api/v1/categories",
        json={"name": "Hacked Category", "slug": "hacked"},
        headers=user_headers,
    )
    assert res_cat.status_code == 403


def test_invalid_token_returns_401(client: TestClient):
    """Verify malformed or invalid token receives 401 Unauthorized."""
    res = client.get("/api/v1/me", headers={"Authorization": "Bearer invalid_garbage_token"})
    assert res.status_code == 401


def test_mass_assignment_protection(
    client: TestClient, user_headers: dict
):
    """Verify client cannot inject unauthorized role or ID modifications in profile update."""
    payload = {
        "name": "Normal Student",
        "role": "ADMIN",  # Ignored by Pydantic schema
        "id": "00000000-0000-0000-0000-000000000000",  # Ignored by Pydantic schema
    }
    res = client.patch("/api/v1/me", json=payload, headers=user_headers)
    assert res.status_code == 200
    data = res.json()
    assert data["role"] == "USER"  # Role remains USER, not ADMIN
