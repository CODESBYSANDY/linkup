# LinkUp Production Backend API

LinkUp is a student opportunity discovery and networking platform designed to help students discover hackathons, internships, jobs, coding competitions, workshops, tech events, and scholarships.

This backend provides a high-performance, modular REST API built with **FastAPI**, **SQLAlchemy 2.x**, **PostgreSQL / Supabase**, **Firebase Admin Authentication**, and **Pydantic v2**.

---

## 1. Production Architecture Overview

```text
                       EXTERNAL SOURCES (e.g. Unstop, Devpost)
                                     │
                                     ▼
                                    n8n
                                     │
                             Secure Ingestion API (X-Ingest-Key)
                                     │
                                     ▼
                            ┌─────────────────┐
                            │     FastAPI     │
                            │                 │
                            │ Routers         │
                            │ Schemas         │
                            │ Dependencies    │
                            │ Services        │
                            │ Firebase Auth   │
                            │ Authorization   │
                            │ Validation      │
                            └────────┬────────┘
                                     │
                                     ▼
                               SQLAlchemy 2.x
                                     │
                                     ▼
                            PostgreSQL / Supabase
                                     │
                                     ▲
                                     │ REST / JSON (Bearer Token)
                                  Flutter
```

---

## 2. Technology Stack

- **Framework**: [FastAPI](https://fastapi.tiangolo.com/) (Python 3.11+)
- **ASGI Web Server**: [Uvicorn](https://www.uvicorn.org/)
- **Authentication**: [Firebase Admin SDK](https://firebase.google.com/docs/admin/setup) (JWT ID Token Verification)
- **Database & ORM**: PostgreSQL via Supabase / Local PostgreSQL 14+, [SQLAlchemy 2.x](https://docs.sqlalchemy.org/en/20/)
- **Database Migrations**: [Alembic](https://alembic.sqlalchemy.org/)
- **Data Validation & Settings**: [Pydantic v2](https://docs.pydantic.dev/) & [Pydantic Settings](https://docs.pydantic.dev/latest/concepts/pydantic_settings/)
- **Testing**: [pytest](https://docs.pytest.org/), [httpx](https://www.python-httpx.org/), [pytest-asyncio](https://pytest-asyncio.readthedocs.io/)
- **Containerization & Deployment**: Docker, Render

---

## 3. Production Database Entities & Schema

| Table | Description | Key Constraints & Indexes |
| :--- | :--- | :--- |
| `users` | Authenticated student accounts | `UNIQUE(firebase_uid)`, `UNIQUE(email)`, Role (`USER`/`ADMIN`) |
| `user_profiles` | Student profile details (bio, skills, college, year) | `UNIQUE(user_id)`, `INDEX(college)`, `INDEX(branch)` |
| `categories` | Opportunity categories (Hackathons, Internships, etc.) | `UNIQUE(slug)`, `UNIQUE(name)` |
| `opportunities` | Hackathons, jobs, internships, contests, workshops | `UNIQUE(source, source_id)`, `INDEX(deadline, status)`, `INDEX(domain)` |
| `saved_opportunities` | Student bookmarked opportunities | `UNIQUE(user_id, opportunity_id)` |
| `posts` | Real community social feed posts | `INDEX(author_id, created_at)`, `INDEX(type)`, Soft Delete (`is_deleted`) |
| `comments` | Threaded comments on community posts | `INDEX(post_id, created_at)`, Soft Delete (`is_deleted`) |
| `post_likes` | Post likes by authenticated students | `UNIQUE(post_id, user_id)` |
| `saved_posts` | Student bookmarked community posts | `UNIQUE(post_id, user_id)` |
| `connections` | Student peer-to-peer connection network | `UNIQUE(requester_id, receiver_id)`, Status (`PENDING`, `ACCEPTED`, `REJECTED`) |
| `groups` | Student interest and practice clubs | `UNIQUE(name)` |
| `group_memberships` | User memberships in groups | `UNIQUE(group_id, user_id)` |
| `mentors` | Faculty, alumni, and industry mentors | `INDEX(name)` |
| `mentor_requests` | Mentorship session requests | `UNIQUE(mentor_id, user_id)` |
| `notifications` | System & social notifications | `INDEX(user_id, is_read, created_at)` |
| `devices` | FCM push notification device tokens | `UNIQUE(token)`, `INDEX(user_id, is_active)` |
| `reports` | Moderation reports against posts/comments/users | `INDEX(target_type, target_id)`, `INDEX(status)` |

---

## 4. Directory Structure

```text
backend/
├── .env                            # Local environment secrets (git-ignored)
├── .env.example                    # Template for environment configuration
├── .gitignore                      # Python, secrets, and cache ignore rules
├── requirements.txt                # Production dependencies
├── Dockerfile                      # Production container configuration
├── alembic.ini                     # Alembic migration configuration
├── README.md                       # Backend documentation
│
├── secrets/                        # Git-ignored local credential storage
│   └── firebase-service-account.json
│
├── alembic/                        # Database migration scripts
│   ├── env.py                      # Dynamic database configuration & metadata
│   └── versions/
│       └── 91728b8baa9a_initial_schema.py
│
├── app/
│   ├── __init__.py
│   ├── main.py                     # FastAPI application factory, lifespan & middleware
│   │
│   ├── core/                       # Core configuration, database & security
│   │   ├── __init__.py
│   │   ├── config.py               # Pydantic Settings configuration
│   │   ├── database.py             # SQLAlchemy 2.x engine & session management
│   │   ├── firebase.py             # Firebase Admin initialization & token verification
│   │   ├── init_db.py              # Reference data seeding (categories)
│   │   └── logging.py              # Centralized structured logging
│   │
│   ├── models/                     # SQLAlchemy 2.x ORM models
│   │   ├── __init__.py
│   │   ├── user.py
│   │   ├── profile.py
│   │   ├── category.py
│   │   ├── opportunity.py
│   │   ├── saved_opportunity.py
│   │   ├── post.py
│   │   ├── comment.py
│   │   ├── post_like.py
│   │   ├── saved_post.py
│   │   ├── connection.py
│   │   ├── group.py
│   │   ├── mentor.py
│   │   ├── notification.py
│   │   ├── device.py
│   │   └── report.py
│   │
│   ├── schemas/                    # Pydantic validation & response schemas
│   │   ├── __init__.py
│   │   ├── common.py
│   │   ├── user.py
│   │   ├── category.py
│   │   ├── opportunity.py
│   │   ├── post.py
│   │   ├── comment.py
│   │   ├── connection.py
│   │   ├── group.py
│   │   ├── mentor.py
│   │   ├── notification.py
│   │   ├── device.py
│   │   ├── report.py
│   │   └── ingest.py
│   │
│   ├── routers/                    # API Route controllers
│   │   ├── __init__.py
│   │   ├── health.py               # /health and /health/ready probes
│   │   ├── users.py                # /me, /users member search
│   │   ├── opportunities.py        # /opportunities CRUD & filters
│   │   ├── posts.py                # /posts feed, comments & likes
│   │   ├── connect.py              # /connections, /groups, /mentors
│   │   ├── notifications.py        # /notifications
│   │   ├── devices.py              # /devices push tokens
│   │   ├── reports.py              # /reports moderation
│   │   └── ingest.py               # /ingest/opportunity from n8n
│   │
│   ├── services/                   # Business logic layer
│   │   ├── __init__.py
│   │   ├── user_service.py
│   │   ├── opportunity_service.py
│   │   ├── post_service.py
│   │   ├── connect_service.py
│   │   ├── notification_service.py
│   │   └── ingest_service.py
│   │
│   └── dependencies/               # Reusable FastAPI dependency injection
│       ├── __init__.py
│       └── auth.py                 # get_current_user, require_admin
│
└── tests/                          # Automated pytest suite
    ├── __init__.py
    ├── conftest.py                 # Isolated test database and mock fixtures
    ├── test_health.py              # Health probes and OpenAPI docs
    ├── test_auth_and_users.py      # Profile management & member search
    ├── test_opportunities.py       # Opportunity CRUD & filters
    ├── test_posts_and_social.py    # Feed, likes, comments & IDOR tests
    ├── test_connect.py             # Peer connections, groups & mentors
    ├── test_ingest.py              # n8n opportunity ingestion & deduplication
    └── test_security.py            # Role enforcement & mass assignment tests
```

---

## 5. Local Setup & Execution

### 1. Prerequisites
- Python 3.11+
- PostgreSQL 14+ running locally or a Supabase PostgreSQL instance

### 2. Environment Setup
```bash
cd backend
python3 -m venv .venv
source .venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
```

### 3. Configure `.env`
Copy the template and verify your database connection:
```bash
cp .env.example .env
```

### 4. Database Migrations
Apply Alembic migrations to create all database tables:
```bash
alembic upgrade head
```

### 5. Start the FastAPI Development Server
```bash
uvicorn app.main:app --reload --port 8000 --host 127.0.0.1
```

### 6. Interactive API Documentation
- **Swagger UI**: [http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs)
- **ReDoc**: [http://127.0.0.1:8000/redoc](http://127.0.0.1:8000/redoc)
- **Health Check**: [http://127.0.0.1:8000/health](http://127.0.0.1:8000/health)
- **Database Readiness**: [http://127.0.0.1:8000/health/ready](http://127.0.0.1:8000/health/ready)

---

## 6. Running the Automated Test Suite

Run all tests across health, auth, opportunities, social feed, connect, ingestion, and security:
```bash
pytest -v
```

---

## 7. Automated n8n Opportunity Ingestion Contract

The backend provides a dedicated, secure endpoint for n8n scrapers to publish opportunities.

- **Endpoint**: `POST /api/v1/ingest/opportunity`
- **Authentication**: `X-Ingest-Key: <N8N_INGEST_SECRET>`

### Example Ingestion Request
```json
{
  "title": "Global AI Hackathon 2026",
  "description": "Multimodal agentic AI innovation sprint.",
  "organization": "Google Cloud & DeepMind",
  "category": "hackathons",
  "domain": "AI / ML",
  "location": "Online / Global",
  "mode": "online",
  "eligibility": "All undergraduate and postgraduate college students.",
  "skills": ["Python", "PyTorch", "Gemini API"],
  "prize": "$25,000 USD Prize Pool",
  "salary": null,
  "deadline": "2026-10-28T23:59:59Z",
  "source": "unstop",
  "source_id": "unstop_ai_1001",
  "registration_url": "https://developers.google.com/events",
  "image_url": "https://example.com/poster.png"
}
```

### Idempotency & Deduplication
- The backend matches on `(source, source_id)` in PostgreSQL.
- If the opportunity already exists, it is **updated** in place without creating duplicate database rows.
- If it is new, it is inserted and automatically assigned to the proper category.

---

## 8. Deployment on Render

1. Connect your GitHub repository to [Render](https://render.com/).
2. Select **Web Service** with Docker environment or Python environment.
3. Configure the following Environment Variables in Render Dashboard:
   - `DATABASE_URL`: Your Supabase connection string (using `postgresql+psycopg://...`)
   - `FIREBASE_SERVICE_ACCOUNT_JSON`: The JSON content of your Firebase service account key
   - `N8N_INGEST_SECRET`: A secure random secret string shared with n8n
   - `ENVIRONMENT`: `production`
   - `DEBUG`: `False`
4. Deploy service. The service will automatically run health checks on `/health`.
