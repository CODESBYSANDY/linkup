"""Health check response schema."""

from pydantic import BaseModel, Field


class HealthResponse(BaseModel):
    """Liveness health check response model."""

    status: str = Field(default="ok", description="Liveness status of the API server")
    version: str = Field(default="1.0.0", description="API version")
    environment: str = Field(default="development", description="Current execution environment")

    model_config = {
        "json_schema_extra": {
            "example": {
                "status": "ok",
                "version": "1.0.0",
                "environment": "development",
            }
        }
    }
