"""Main FastAPI application entrypoint.

Configures application lifespan, Firebase initialization, CORS middleware,
exception handling, and mounts all API v1 routers.
"""

from contextlib import asynccontextmanager
from typing import AsyncGenerator
from fastapi import FastAPI, Request, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from app.core.config import settings
from app.core.database import SessionLocal
from app.core.firebase import initialize_firebase
from app.core.init_db import seed_static_reference_data
from app.core.logging import logger, setup_logging
from app.routers import (
    connect,
    devices,
    health,
    ingest,
    notifications,
    opportunities,
    posts,
    reports,
    users,
)


@asynccontextmanager
async def lifespan(app: FastAPI) -> AsyncGenerator[None, None]:
    """Application lifespan context manager for startup and shutdown events."""
    # Startup
    setup_logging()
    logger.info(
        "Starting up %s v%s in %s mode",
        settings.PROJECT_NAME,
        settings.VERSION,
        settings.ENVIRONMENT,
    )

    # Initialize Firebase Admin SDK
    initialize_firebase()

    # Seed static reference categories
    if not settings.TESTING:
        try:
            with SessionLocal() as db:
                seed_static_reference_data(db)
        except Exception as exc:
            logger.warning("Database seeding during startup skipped / deferred: %s", exc)

    logger.info("OpenAPI Docs available at /docs and /redoc")
    logger.info("CORS allowed origins: %s", settings.CORS_ORIGINS)

    yield

    # Shutdown
    logger.info("Shutting down %s...", settings.PROJECT_NAME)


def create_application() -> FastAPI:
    """Application factory to construct and configure the FastAPI instance."""
    application = FastAPI(
        title=settings.PROJECT_NAME,
        version=settings.VERSION,
        description=settings.DESCRIPTION,
        docs_url="/docs",
        redoc_url="/redoc",
        openapi_url="/openapi.json",
        lifespan=lifespan,
    )

    # Cross-Origin Resource Sharing (CORS)
    application.add_middleware(
        CORSMiddleware,
        allow_origins=settings.CORS_ORIGINS,
        allow_origin_regex=r"^http://(localhost|127\.0\.0\.1)(:[0-9]+)?$",
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    # Global Exception Handler (Never leak DB secrets or stack traces to clients)
    @application.exception_handler(Exception)
    async def global_exception_handler(request: Request, exc: Exception):
        logger.error(
            "Unhandled server exception on %s %s: %s",
            request.method,
            request.url.path,
            exc,
            exc_info=True,
        )
        return JSONResponse(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            content={
                "error": {
                    "code": "INTERNAL_SERVER_ERROR",
                    "message": "An unexpected server error occurred. Please try again later.",
                }
            },
        )

    # Mount Health Check Router
    application.include_router(health.router)

    # Mount Business API v1 Routers
    api_v1_prefix = settings.API_V1_STR
    application.include_router(users.router, prefix=api_v1_prefix)
    application.include_router(opportunities.router, prefix=api_v1_prefix)
    application.include_router(posts.router, prefix=api_v1_prefix)
    application.include_router(connect.router, prefix=api_v1_prefix)
    application.include_router(notifications.router, prefix=api_v1_prefix)
    application.include_router(devices.router, prefix=api_v1_prefix)
    application.include_router(reports.router, prefix=api_v1_prefix)
    application.include_router(ingest.router, prefix=api_v1_prefix)

    @application.get("/", include_in_schema=False)
    def root_redirect():
        """Root endpoint returning basic service information."""
        return JSONResponse(
            content={
                "name": settings.PROJECT_NAME,
                "version": settings.VERSION,
                "environment": settings.ENVIRONMENT,
                "docs_url": "/docs",
                "redoc_url": "/redoc",
                "health_url": "/health",
                "ready_url": "/health/ready",
            }
        )

    return application


app = create_application()
