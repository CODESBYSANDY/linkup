# LINKUP — Production Frontend API Integration & Architecture Guide

This document describes the production client-server integration between the LINKUP Flutter Frontend and the FastAPI / PostgreSQL / Supabase backend.

---

## 1. Architecture Overview

LINKUP follows a clean **Thin Client** architecture where the server is the single source of truth for all business logic, authorization, data persistence, and identity mapping.

```text
               FIREBASE AUTHENTICATION
                         │
                         │ ID Token (JWT)
                         ▼
┌────────────────────────────────────────────────────────┐
│                   FLUTTER CLIENT                       │
│                                                        │
│  UI Views / Widgets (Riko Opportunity Scout Visuals)   │
│                          │                             │
│                          ▼                             │
│  ChangeNotifiers / ValueNotifiers / State Controllers  │
│                          │                             │
│                          ▼                             │
│  Domain Repositories (Auth, Opps, Community, Connect)  │
│                          │                             │
│                          ▼                             │
│  Centralized ApiClient (HTTP/JSON/Auth Token)          │
└──────────────────────────┬─────────────────────────────┘
                           │
                           │ HTTPS / Bearer Token
                           ▼
┌────────────────────────────────────────────────────────┐
│                   FASTAPI REST API                     │
│                                                        │
│  Firebase Admin Token Verification                     │
│  User & Profile Provisioning (/api/v1/me)              │
│  Opportunities Engine (/api/v1/opportunities)          │
│  Community & Threaded Comments (/api/v1/posts)         │
│  Connections & Networking (/api/v1/connections)        │
│  Groups & Mentors (/api/v1/groups, /api/v1/mentors)    │
│  Notification Pipeline (/api/v1/notifications)         │
│  Moderation & Reporting (/api/v1/reports)              │
│  n8n Ingestion Webhook (/api/v1/ingest/opportunity)    │
└──────────────────────────┬─────────────────────────────┘
                           │
                           ▼
┌────────────────────────────────────────────────────────┐
│            POSTGRESQL / SUPABASE DATABASE              │
│                                                        │
│  users, profiles, posts, comments, likes, saves,       │
│  connections, groups, memberships, mentors, reports    │
└────────────────────────────────────────────────────────┘
```

---

## 2. Security Invariant (Supabase & Firebase)

1. **NO Supabase Secret / Service-Role Keys**:
   - The Flutter application **never** stores or uses Supabase service-role keys or database passwords.
   - All privileged operations are executed strictly through FastAPI endpoints authenticated via Firebase Bearer tokens.
2. **Author Identity Derivation**:
   - The Flutter frontend does **not** specify `author_id` in write operations (posts, comments, likes, saves).
   - FastAPI verifies the Firebase ID token and derives `author_id = authenticated_user.id` on the server.

---

## 3. Environment & Configuration

API base URLs are managed centrally in `lib/core/config/app_config.dart`.

### Build & Run Commands

- **Local Development (macOS / Web / Desktop)**:
  ```bash
  flutter run -d chrome
  # Defaults to: http://127.0.0.1:8000/api/v1
  ```

- **Android Emulator**:
  ```bash
  flutter run
  # Automatically uses Android host bridge: http://10.0.2.2:8000/api/v1
  ```

- **Production / Custom Deployed Backend**:
  ```bash
  flutter run --dart-define=API_BASE_URL=https://api.linkup.yourdomain.com/api/v1
  ```

---

## 4. Authentication Flow

1. **Firebase Login / Register**:
   - User inputs credentials in Flutter.
   - Flutter authenticates with Firebase Auth.
   - Flutter retrieves the ID Token: `user.getIdToken()`.
2. **FastAPI Profile Sync**:
   - Flutter sets `Authorization: Bearer <token>` in `ApiClient`.
   - Flutter requests `GET /api/v1/me`.
   - FastAPI verifies the token with Firebase Admin SDK, auto-provisions the PostgreSQL user/profile on first login, and returns the profile.
3. **Session Restoration**:
   - App startup loads cached session from storage and calls `GET /api/v1/me` to refresh user details.

---

## 5. API Endpoints Specification

### 5.1 Identity & Profile (`/api/v1/me`)

| Method | Endpoint | Description | Request Body | Response |
|---|---|---|---|---|
| `GET` | `/api/v1/me` | Authoritative profile for current user | None | `UserProfileResponse` |
| `PATCH` | `/api/v1/me` | Update profile bio, college, skills, interests | `{ "full_name": "...", "bio": "...", "skills": [...] }` | `UserProfileResponse` |

### 5.2 Opportunities (`/api/v1/opportunities`)

| Method | Endpoint | Description | Query Parameters / Body | Response |
|---|---|---|---|---|
| `GET` | `/api/v1/opportunities` | Paginated opportunity list with search & filter | `search`, `category`, `domain`, `mode`, `skills`, `sort`, `page`, `limit` | `{ "items": [...], "total": 100, "page": 1, "has_next": true }` |
| `GET` | `/api/v1/opportunities/{id}` | Detailed opportunity view | None | `OpportunityResponse` |
| `POST` | `/api/v1/opportunities/{id}/save` | Bookmark opportunity | None | `{ "saved": true }` |
| `DELETE` | `/api/v1/opportunities/{id}/save` | Remove bookmark | None | `{ "saved": false }` |
| `GET` | `/api/v1/me/saved-opportunities` | Current user's saved opportunities | None | `{ "items": [...] }` |

### 5.3 Community Discussions (`/api/v1/posts`)

| Method | Endpoint | Description | Query / Body | Response |
|---|---|---|---|---|
| `GET` | `/api/v1/posts` | Community feed | `search`, `type`, `tag`, `group_id`, `page`, `limit` | `{ "items": [...], "total": 50, "page": 1 }` |
| `POST` | `/api/v1/posts` | Create new post | `{ "title": "...", "content": "...", "type": "knowledge", "tags": [...] }` | `PostResponse` |
| `PATCH` | `/api/v1/posts/{id}` | Edit post (author only) | `{ "title": "...", "content": "...", "tags": [...] }` | `PostResponse` |
| `DELETE` | `/api/v1/posts/{id}` | Delete post (author only) | None | `{ "success": true }` |
| `POST` | `/api/v1/posts/{id}/like` | Toggle upvote on post | None | `{ "likes_count": 12, "is_liked": true }` |
| `POST` | `/api/v1/posts/{id}/comments` | Add comment to post | `{ "content": "..." }` | `CommentResponse` |
| `DELETE` | `/api/v1/comments/{id}` | Delete comment | None | `{ "success": true }` |
| `POST` | `/api/v1/posts/{id}/save` | Bookmark community post | None | `{ "saved": true }` |
| `GET` | `/api/v1/me/saved-posts` | Current user's saved posts | None | `{ "items": [...] }` |

### 5.4 Connect & Members (`/api/v1/users`, `/api/v1/connections`)

| Method | Endpoint | Description | Query / Body | Response |
|---|---|---|---|---|
| `GET` | `/api/v1/users` | Registered student directory | `query`, `page`, `limit` | `{ "items": [...], "total": 25 }` |
| `GET` | `/api/v1/users/{id}` | Public student profile | None | `UserPublicResponse` |
| `POST` | `/api/v1/connections/{user_id}` | Send/toggle connection request | None | `{ "status": "PENDING" }` |
| `GET` | `/api/v1/connections` | Active connections list | None | `{ "items": [...] }` |

### 5.5 Groups & Mentors (`/api/v1/groups`, `/api/v1/mentors`)

| Method | Endpoint | Description | Query / Body | Response |
|---|---|---|---|---|
| `GET` | `/api/v1/groups` | Technical communities | None | `List<GroupResponse>` |
| `POST` | `/api/v1/groups/{id}/join` | Join/leave group | None | `{ "joined": true }` |
| `GET` | `/api/v1/mentors` | Knowledge mentors list | None | `List<MentorResponse>` |
| `POST` | `/api/v1/mentors/{id}/request` | Request 1-on-1 mentorship | None | `{ "requested": true }` |

### 5.6 Notifications & Moderation (`/api/v1/notifications`, `/api/v1/reports`)

| Method | Endpoint | Description | Query / Body | Response |
|---|---|---|---|---|
| `GET` | `/api/v1/notifications` | User notifications list | `page`, `limit` | `{ "items": [...] }` |
| `PATCH` | `/api/v1/notifications/{id}/read` | Mark single as read | None | `{ "success": true }` |
| `POST` | `/api/v1/notifications/read-all` | Mark all as read | None | `{ "success": true }` |
| `POST` | `/api/v1/reports` | Report post/comment/user | `{ "target_type": "post", "target_id": "...", "reason": "Spam", "description": "..." }` | `{ "id": "rep_123" }` |

---

## 6. Error Handling & User-Friendly Messages

HTTP error codes are intercepted by `ApiException` in `lib/core/network/api_exceptions.dart`:

- `400`: *"Invalid request. Please verify the information provided."*
- `401`: *"Your session has expired. Please sign in again."*
- `403`: *"You don't have permission to perform this action."*
- `404`: *"The requested item could not be found."*
- `409`: *"This action has already been performed."*
- `422`: *"Please check the information you entered."*
- `429`: *"Too many requests. Please wait a moment and try again."*
- `500/502/503`: *"Server is temporarily unavailable. Please try again shortly."*
- `Offline/SocketException`: *"You're offline. Check your internet connection and try again."*

---

## 7. Automated Test Suite

Run analyzer and tests via:

```bash
cd frontend
flutter analyze
flutter test
```
