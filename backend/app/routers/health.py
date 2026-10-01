"""Health and readiness check router."""

from fastapi import APIRouter, HTTPException, status
from pydantic import BaseModel, Field
from app.core.config import settings
from app.core.database import check_database_connection
from app.schemas.health import HealthResponse

router = APIRouter(tags=["Health"])


class ReadinessResponse(BaseModel):
    """Database readiness probe response."""
    status: str = Field(default="ready")
    database: str = Field(default="connected")
    environment: str = Field(default="development")


@router.get(
    "/health",
    response_model=HealthResponse,
    status_code=status.HTTP_200_OK,
    summary="Service Liveness Check",
    description="Returns HTTP 200 OK with server status. Used by hosting platforms to verify container liveness.",
)
@router.get(
    "/health/live",
    response_model=HealthResponse,
    include_in_schema=False,
)
def get_health() -> HealthResponse:
    """Return liveness health status."""
    return HealthResponse(
        status="ok",
        version=settings.VERSION,
        environment=settings.ENVIRONMENT,
    )


@router.get(
    "/health/ready",
    response_model=ReadinessResponse,
    summary="Service & Database Readiness Check",
    description="Pings PostgreSQL to ensure database connection pool is active and ready to accept traffic.",
)
def get_readiness() -> ReadinessResponse:
    """Return database readiness status."""
    is_db_connected = check_database_connection()
    if not is_db_connected:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Database connection is unavailable.",
        )
    return ReadinessResponse(
        status="ready",
        database="connected",
        environment=settings.ENVIRONMENT,
    )
