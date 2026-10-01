"""Tests for automated n8n opportunity ingestion."""

from datetime import datetime, timedelta, timezone
from fastapi.testclient import TestClient
from app.core.config import settings


def test_ingest_opportunity_unauthorized(client: TestClient):
    """Verify ingestion without secret key returns 401 Unauthorized."""
    payload = {
        "title": "AI Innovation Sprint",
        "description": "Scraped hackathon",
        "organization": "Google Cloud",
        "category": "hackathon",
        "deadline": (datetime.now(timezone.utc) + timedelta(days=20)).isoformat(),
        "registration_url": "https://example.com/register",
        "source": "unstop",
        "source_id": "ext_12345",
    }
    # No header
    res_no_key = client.post("/api/v1/ingest/opportunity", json=payload)
    assert res_no_key.status_code == 401

    # Wrong header
    res_wrong_key = client.post(
        "/api/v1/ingest/opportunity", json=payload, headers={"X-Ingest-Key": "wrong-secret"}
    )
    assert res_wrong_key.status_code == 401


def test_ingest_opportunity_idempotency_and_deduplication(client: TestClient):
    """Verify n8n ingestion creates on first call and updates on subsequent duplicate calls."""
    ingest_headers = {"X-Ingest-Key": settings.N8N_INGEST_SECRET}
    deadline = (datetime.now(timezone.utc) + timedelta(days=25)).isoformat()

    payload = {
        "title": "Global AI Hackathon 2026",
        "description": "Original description from scraper",
        "organization": "DeepMind",
        "category": "hackathons",
        "domain": "AI / ML",
        "location": "Online",
        "mode": "online",
        "eligibility": "All college students",
        "skills": ["Python", "PyTorch"],
        "prize": "$25,000",
        "deadline": deadline,
        "registration_url": "https://deepmind.google/events",
        "source": "unstop",
        "source_id": "unstop_ai_999",
    }

    # 1. First Ingestion -> Status: "created"
    res1 = client.post("/api/v1/ingest/opportunity", json=payload, headers=ingest_headers)
    assert res1.status_code == 200
    data1 = res1.json()
    assert data1["status"] == "created"
    opp_id = data1["id"]

    # 2. Updated Payload with same (source, source_id)
    payload["title"] = "Global AI Hackathon 2026 (Updated Prize Pool)"
    payload["prize"] = "$50,000"

    # 3. Second Ingestion -> Status: "updated", same ID
    res2 = client.post("/api/v1/ingest/opportunity", json=payload, headers=ingest_headers)
    assert res2.status_code == 200
    data2 = res2.json()
    assert data2["status"] == "updated"
    assert data2["id"] == opp_id  # Preserves database identity without inserting duplicate
