"""Pytest fixtures and test database configuration."""

import os
import uuid
import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, Session

# Set TESTING environment variable before importing application
os.environ["TESTING"] = "True"
os.environ["ENVIRONMENT"] = "testing"

from app.core.config import settings
from app.core.database import Base, get_db
from app.core.init_db import seed_static_reference_data
from app.main import app
from app.models.user import User, UserRole
from app.models.profile import UserProfile

# Test database engine
TEST_DB_URL = settings.TEST_DATABASE_URL or "postgresql+psycopg://postgres:postgres@localhost:5432/linkup_test"
test_engine = create_engine(TEST_DB_URL, pool_pre_ping=True)
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=test_engine, expire_on_commit=False)


@pytest.fixture(scope="session", autouse=True)
def setup_test_database():
    """Create all tables in the test database once per test session."""
    Base.metadata.drop_all(bind=test_engine)
    Base.metadata.create_all(bind=test_engine)
    with TestingSessionLocal() as db:
        seed_static_reference_data(db)
    yield
    Base.metadata.drop_all(bind=test_engine)


@pytest.fixture
def db_session():
    """Yield an isolated database session rolled back after each test."""
    connection = test_engine.connect()
    transaction = connection.begin()
    session = TestingSessionLocal(bind=connection)

    yield session

    session.close()
    transaction.rollback()
    connection.close()


@pytest.fixture
def client(db_session: Session):
    """FastAPI TestClient with overridden get_db dependency."""
    def override_get_db():
        try:
            yield db_session
        finally:
            pass

    app.dependency_overrides[get_db] = override_get_db
    with TestClient(app) as test_client:
        yield test_client
    app.dependency_overrides.clear()


@pytest.fixture
def test_user(db_session: Session) -> User:
    """Create a standard test user in the database."""
    uid = f"user_{uuid.uuid4().hex[:8]}"
    user = User(
        firebase_uid=uid,
        email=f"{uid}@student.linkup.dev",
        name="Test Student",
        role=UserRole.USER,
        avatar_initials="TS",
        is_active=True,
    )
    db_session.add(user)
    db_session.flush()

    profile = UserProfile(
        user_id=user.id,
        college="KPR Institute of Engineering and Technology",
        branch="Computer Science & Engineering",
        year="Year 3",
        bio="Student developer testing LinkUp API",
        skills=["Python", "Flutter"],
        interests=["Cybersecurity", "AI / ML"],
        is_onboarded=True,
    )
    db_session.add(profile)
    db_session.commit()
    db_session.refresh(user)
    return user


@pytest.fixture
def test_user_2(db_session: Session) -> User:
    """Create a second distinct test user."""
    uid = f"user_{uuid.uuid4().hex[:8]}"
    user = User(
        firebase_uid=uid,
        email=f"{uid}@student.linkup.dev",
        name="Second Student",
        role=UserRole.USER,
        avatar_initials="SS",
        is_active=True,
    )
    db_session.add(user)
    db_session.flush()

    profile = UserProfile(
        user_id=user.id,
        college="PSG College of Technology",
        branch="Information Technology",
        year="Year 2",
        bio="Peer student developer",
        skills=["Go", "PostgreSQL"],
        interests=["Cloud & DevOps"],
        is_onboarded=True,
    )
    db_session.add(profile)
    db_session.commit()
    db_session.refresh(user)
    return user


@pytest.fixture
def admin_user(db_session: Session) -> User:
    """Create an administrator test user."""
    uid = f"admin_{uuid.uuid4().hex[:8]}"
    user = User(
        firebase_uid=uid,
        email=f"{uid}@admin.linkup.dev",
        name="Admin User",
        role=UserRole.ADMIN,
        avatar_initials="AU",
        is_active=True,
    )
    db_session.add(user)
    db_session.flush()

    profile = UserProfile(
        user_id=user.id,
        college="LinkUp HQ",
        branch="Platform Engineering",
        year="Staff",
        bio="Platform Administrator",
        is_onboarded=True,
    )
    db_session.add(profile)
    db_session.commit()
    db_session.refresh(user)
    return user


@pytest.fixture
def user_headers(test_user: User) -> dict:
    """Authorization headers for standard user."""
    return {"Authorization": f"Bearer test_token_{test_user.firebase_uid}"}


@pytest.fixture
def user_2_headers(test_user_2: User) -> dict:
    """Authorization headers for second user."""
    return {"Authorization": f"Bearer test_token_{test_user_2.firebase_uid}"}


@pytest.fixture
def admin_headers(admin_user: User) -> dict:
    """Authorization headers for admin user."""
    return {"Authorization": f"Bearer test_token_{admin_user.firebase_uid}"}
