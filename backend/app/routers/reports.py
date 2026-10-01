"""Content moderation report endpoints."""

import uuid
from datetime import datetime, timezone
from typing import List
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.dependencies.auth import get_current_user, require_admin
from app.models.report import Report, ReportStatus
from app.models.user import User
from app.schemas.common import MessageResponse
from app.schemas.report import ReportCreate, ReportResponse, ReportStatusUpdate

router = APIRouter(tags=["Moderation & Reports"])


@router.post(
    "/reports",
    response_model=ReportResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Submit content moderation report",
)
def submit_report(
    payload: ReportCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> ReportResponse:
    """Submit report against post, comment, or user."""
    target_uuid = uuid.UUID(payload.target_id)
    report = Report(
        reporter_id=current_user.id,
        target_type=payload.target_type,
        target_id=target_uuid,
        reason=payload.reason,
        description=payload.description,
        status=ReportStatus.PENDING,
    )
    db.add(report)
    db.commit()
    db.refresh(report)
    return ReportResponse(
        id=str(report.id),
        reporter_id=str(report.reporter_id),
        target_type=report.target_type,
        target_id=str(report.target_id),
        reason=report.reason,
        description=report.description,
        status=report.status,
        created_at=report.created_at,
    )


@router.get(
    "/admin/reports",
    response_model=List[ReportResponse],
    summary="List moderation reports (Admin)",
)
def list_reports(
    admin_user: User = Depends(require_admin),
    db: Session = Depends(get_db),
) -> List[ReportResponse]:
    """List reports."""
    reports = db.execute(select(Report).order_by(Report.created_at.desc())).scalars().all()
    return [
        ReportResponse(
            id=str(r.id),
            reporter_id=str(r.reporter_id),
            target_type=r.target_type,
            target_id=str(r.target_id),
            reason=r.reason,
            description=r.description,
            status=r.status,
            created_at=r.created_at,
        )
        for r in reports
    ]


@router.patch(
    "/admin/reports/{report_id}",
    response_model=ReportResponse,
    summary="Update moderation report status (Admin)",
)
def update_report_status(
    report_id: uuid.UUID,
    payload: ReportStatusUpdate,
    admin_user: User = Depends(require_admin),
    db: Session = Depends(get_db),
) -> ReportResponse:
    """Update report status."""
    report = db.get(Report, report_id)
    if not report:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Report not found.",
        )
    report.status = payload.status
    report.reviewed_by = admin_user.id
    report.reviewed_at = datetime.now(timezone.utc)
    db.commit()
    db.refresh(report)
    return ReportResponse(
        id=str(report.id),
        reporter_id=str(report.reporter_id),
        target_type=report.target_type,
        target_id=str(report.target_id),
        reason=report.reason,
        description=report.description,
        status=report.status,
        created_at=report.created_at,
    )
