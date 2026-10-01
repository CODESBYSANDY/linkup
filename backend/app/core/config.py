"""Application configuration management using Pydantic Settings v2.

Provides centralized, typed, and validated configuration loaded from
environment variables and/or .env files.
"""

from functools import lru_cache
from typing import List, Optional, Union
from pydantic import field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """LinkUp Application Settings."""

    # Project metadata
    PROJECT_NAME: str = "LinkUp API"
    VERSION: str = "1.0.0"
    DESCRIPTION: str = (
        "LinkUp Backend API: Student Opportunity Discovery & Networking Platform. "
        "Provides REST endpoints for hackathons, internships, jobs, workshops, "
        "user management, saved opportunities, real social feed, and automated n8n ingestion."
    )
    API_V1_STR: str = "/api/v1"

    # Environment
    ENVIRONMENT: str = "development"
    DEBUG: bool = True
    TESTING: bool = False

    # CORS Configuration
    CORS_ORIGINS: Union[List[str], str] = [
        "http://localhost:3000",
        "http://localhost:8000",
        "http://127.0.0.1:8000",
    ]

    @field_validator("CORS_ORIGINS", mode="before")
    @classmethod
    def assemble_cors_origins(cls, v: Union[str, List[str]]) -> List[str]:
        """Parse comma-separated string or list into a list of valid origins."""
        if isinstance(v, str) and not v.startswith("["):
            return [i.strip() for i in v.split(",") if i.strip()]
        elif isinstance(v, list):
            return v
        return []

    # Database Configuration (PostgreSQL / Supabase)
    DATABASE_URL: str = "postgresql+psycopg://postgres:postgres@localhost:5432/linkup"
    TEST_DATABASE_URL: str = "postgresql+psycopg://postgres:postgres@localhost:5432/linkup_test"

    # Firebase Authentication
    FIREBASE_CREDENTIALS_PATH: Optional[str] = "secrets/firebase-service-account.json"
    FIREBASE_SERVICE_ACCOUNT_JSON: Optional[str] = None
    FIREBASE_PROJECT_ID: Optional[str] = "link-up-e0998"

    # Ingestion Security (n8n API Key)
    N8N_INGEST_SECRET: str = "dev-insecure-ingest-secret"

    # Pagination Defaults
    DEFAULT_PAGE_LIMIT: int = 20
    MAX_PAGE_LIMIT: int = 100

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=True,
        extra="ignore",
    )


@lru_cache()
def get_settings() -> Settings:
    """Return cached settings instance."""
    return Settings()


settings = get_settings()
