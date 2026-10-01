"""Tests for health and readiness probes."""

from fastapi.testclient import TestClient


def test_health_liveness(client: TestClient):
    """Verify GET /health returns 200 OK and valid status."""
    response = client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "ok"
    assert "version" in data


def test_health_readiness(client: TestClient):
    """Verify GET /health/ready checks PostgreSQL connection and returns 200."""
    response = client.get("/health/ready")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "ready"
    assert data["database"] == "connected"


def test_swagger_and_openapi_docs(client: TestClient):
    """Verify OpenAPI and Swagger UI endpoints."""
    assert client.get("/docs").status_code == 200
    assert client.get("/redoc").status_code == 200
    res = client.get("/openapi.json")
    assert res.status_code == 200
    assert "/api/v1/opportunities" in res.json()["paths"]
