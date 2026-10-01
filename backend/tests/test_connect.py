"""Tests for peer connections, interest groups, and mentors."""

from fastapi.testclient import TestClient
from sqlalchemy.orm import Session

from app.models.group import Group
from app.models.mentor import Mentor
from app.models.user import User


def test_peer_connection_flow(
    client: TestClient, test_user: User, test_user_2: User, user_headers: dict, user_2_headers: dict
):
    """Verify peer connection toggle: Connect -> Pending -> Connected -> Disconnect."""
    # 1. User 1 sends connection request to User 2
    res1 = client.post(f"/api/v1/connections/{test_user_2.id}", headers=user_headers)
    assert res1.status_code == 200
    assert res1.json()["status"] == "Pending"

    # 2. User 2 accepts by toggling connection with User 1
    res2 = client.post(f"/api/v1/connections/{test_user.id}", headers=user_2_headers)
    assert res2.status_code == 200
    assert res2.json()["status"] == "Connected"


def test_group_join_and_mentor_request(
    client: TestClient, test_user: User, user_headers: dict, db_session: Session
):
    """Verify student can join a group and request mentorship."""
    # Create test group
    group = Group(
        name="Cybersecurity & CTF Builders",
        category="Cybersecurity",
        description="Room writeups and CTF team formation",
        members_count=0,
    )
    db_session.add(group)

    # Create test mentor
    mentor = Mentor(
        name="Rahul Sharma",
        role="Security Researcher",
        college="CrowdStrike",
        skills=["Wireshark", "Linux"],
    )
    db_session.add(mentor)
    db_session.commit()

    # 1. Join group
    join_res = client.post(f"/api/v1/groups/{group.id}/join", headers=user_headers)
    assert join_res.status_code == 200
    assert join_res.json()["is_joined"] is True

    # 2. Request mentorship
    req_res = client.post(f"/api/v1/mentors/{mentor.id}/request", headers=user_headers)
    assert req_res.status_code == 200
    assert req_res.json()["is_requested"] is True
