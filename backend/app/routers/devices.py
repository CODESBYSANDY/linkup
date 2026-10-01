"""Device registration endpoints for push notifications."""

from fastapi import APIRouter, Depends, status
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.dependencies.auth import get_current_user
from app.models.device import Device
from app.models.user import User
from app.schemas.common import MessageResponse
from app.schemas.device import DeviceRegisterRequest, DeviceResponse

router = APIRouter(tags=["Devices"])


@router.post(
    "/devices",
    response_model=DeviceResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Register device push notification token",
)
def register_device(
    payload: DeviceRegisterRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> DeviceResponse:
    """Register or update device token."""
    stmt = select(Device).where(Device.token == payload.token)
    device = db.execute(stmt).scalar_one_or_none()

    if device:
        device.user_id = current_user.id
        device.platform = payload.platform
        device.is_active = True
    else:
        device = Device(
            user_id=current_user.id,
            token=payload.token,
            platform=payload.platform,
            is_active=True,
        )
        db.add(device)

    db.commit()
    db.refresh(device)
    return DeviceResponse(
        id=str(device.id),
        token=device.token,
        platform=device.platform,
        is_active=device.is_active,
        created_at=device.created_at,
    )


@router.delete(
    "/devices/{token}",
    response_model=MessageResponse,
    summary="Unregister device token",
)
def unregister_device(
    token: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> MessageResponse:
    """Unregister device token."""
    stmt = select(Device).where(Device.token == token, Device.user_id == current_user.id)
    device = db.execute(stmt).scalar_one_or_none()
    if device:
        db.delete(device)
        db.commit()
    return MessageResponse(message="Device unregistered.")
