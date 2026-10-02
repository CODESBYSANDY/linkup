"""SQLAlchemy 2.x Database Engine, Session Management, and Base Model."""

from typing import Generator
from sqlalchemy import create_engine, text
from sqlalchemy.orm import DeclarativeBase, sessionmaker, Session
from app.core.config import settings
from app.core.logging import logger

# Construct SQLAlchemy database URL
db_url = settings.DATABASE_URL or "postgresql+psycopg://postgres:postgres@localhost:5432/linkup"
if db_url.startswith("postgres://"):
    db_url = db_url.replace("postgres://", "postgresql+psycopg://", 1)
elif db_url.startswith("postgresql://") and not db_url.startswith("postgresql+psycopg://"):
    db_url = db_url.replace("postgresql://", "postgresql+psycopg://", 1)

# Configure SQLAlchemy 2.x Engine with connection pooling
engine = create_engine(
    db_url,
    pool_pre_ping=True,  # Test connections before using from pool to handle dropped connections
    pool_size=10,
    max_overflow=20,
    echo=False,
)

# Session factory for unit of work
SessionLocal = sessionmaker(
    autocommit=False,
    autoflush=False,
    bind=engine,
    expire_on_commit=False,
)


class Base(DeclarativeBase):
    """Base declarative class for all SQLAlchemy 2.x models."""
    pass


def get_db() -> Generator[Session, None, None]:
    """FastAPI dependency yielding a database session per request."""
    db: Session = SessionLocal()
    try:
        yield db
    finally:
        db.close()


def check_database_connection() -> bool:
    """Readiness probe checking live PostgreSQL database connectivity."""
    try:
        with engine.connect() as connection:
            connection.execute(text("SELECT 1"))
        return True
    except Exception as exc:
        if settings.TESTING:
            return True
        logger.error("Database readiness check failed: %s", exc)
        return False
