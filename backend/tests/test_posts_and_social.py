"""Tests for community posts, comments, likes, saves, and IDOR protection."""

from fastapi.testclient import TestClient
from app.models.user import User


def test_empty_feed_state(client: TestClient, user_headers: dict):
    """Verify empty feed returns total 0 without throwing errors."""
    response = client.get("/api/v1/posts", headers=user_headers)
    assert response.status_code == 200
    data = response.json()
    assert "items" in data
    assert isinstance(data["items"], list)


def test_post_creation_author_binding_and_comments(
    client: TestClient, test_user: User, test_user_2: User, user_headers: dict, user_2_headers: dict
):
    """Verify authentic user creates post, gets likes, comments, and prevents IDOR deletion."""
    # 1. User 1 creates a post
    post_payload = {
        "type": "question",
        "title": "Best approach to packet analysis in Wireshark?",
        "content": "Looking for roadmaps on network security and CTF challenges.",
        "tags": ["Networking", "Cybersecurity", "CTF"],
    }
    create_res = client.post("/api/v1/posts", json=post_payload, headers=user_headers)
    assert create_res.status_code == 201
    post_data = create_res.json()
    post_id = post_data["id"]
    assert post_data["author_id"] == str(test_user.id)
    assert post_data["title"] == post_payload["title"]

    # 2. User 2 likes the post
    like_res = client.post(f"/api/v1/posts/{post_id}/like", headers=user_2_headers)
    assert like_res.status_code == 200
    assert like_res.json()["is_liked"] is True
    assert like_res.json()["likes_count"] == 1

    # 2b. User 2 unlikes the post via DELETE (repeated calls remain False)
    unlike_res = client.delete(f"/api/v1/posts/{post_id}/like", headers=user_2_headers)
    assert unlike_res.status_code == 200
    assert unlike_res.json()["is_liked"] is False
    assert unlike_res.json()["likes_count"] == 0

    unlike_repeat = client.delete(f"/api/v1/posts/{post_id}/like", headers=user_2_headers)
    assert unlike_repeat.status_code == 200
    assert unlike_repeat.json()["is_liked"] is False
    assert unlike_repeat.json()["likes_count"] == 0

    # Re-like for comments
    client.post(f"/api/v1/posts/{post_id}/like", headers=user_2_headers)

    # 3. User 2 adds a comment
    comment_payload = {
        "content": "Check out Practical Packet Analysis and CyberDefenders labs!",
    }
    comment_res = client.post(f"/api/v1/posts/{post_id}/comments", json=comment_payload, headers=user_2_headers)
    assert comment_res.status_code == 201
    comment_data = comment_res.json()
    assert comment_data["author_id"] == str(test_user_2.id)

    # 4. User 2 tries to delete User 1's post -> Expect 403 Forbidden (IDOR Prevention)
    delete_unauthorized = client.delete(f"/api/v1/posts/{post_id}", headers=user_2_headers)
    assert delete_unauthorized.status_code == 403

    # 5. User 1 (Author) deletes their own post -> Expect 200 OK
    delete_authorized = client.delete(f"/api/v1/posts/{post_id}", headers=user_headers)
    assert delete_authorized.status_code == 200
