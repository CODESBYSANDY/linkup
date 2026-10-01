"""Automated opportunity ingestion endpoint for n8n web scraping workflows."""

from typing import Optional
from fastapi import APIRouter, Depends, Header, HTTPException, status
from sqlalchemy.orm import Session

from app.core.config import settings
from app.core.database import get_db
from app.schemas.ingest import IngestOpportunityPayload, IngestResponse
from app.services import ingest_service

router = APIRouter(prefix="/ingest", tags=["n8n Ingestion"])


def verify_ingest_key(
    x_ingest_key: Optional[str] = Header(None, alias="X-Ingest-Key"),
) -> str:
    """Verify secret token sent by n8n workflow in X-Ingest-Key header."""
    if not x_ingest_key:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Missing X-Ingest-Key ingestion authentication header.",
        )
    if x_ingest_key != settings.N8N_INGEST_SECRET:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid ingestion secret key.",
        )
    return x_ingest_key


@router.post(
    "/opportunity",
    response_model=IngestResponse,
    status_code=status.HTTP_200_OK,
    summary="Ingest scraped opportunity from n8n",
    description="Secure, idempotent ingestion endpoint for external web scrapers (Unstop, Devpost, etc.). Deduplicates on (source, source_id) and performs safe atomic upsert.",
)
def ingest_opportunity_endpoint(
    payload: IngestOpportunityPayload,
    _auth: str = Depends(verify_ingest_key),
    db: Session = Depends(get_db),
) -> IngestResponse:
    """Idempotently ingest an opportunity."""
    return ingest_service.ingest_opportunity(payload, db)
