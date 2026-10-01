"""Device push notification token schemas."""

from datetime import datetime
from pydantic import BaseModel, ConfigDict, Field


class DeviceRegisterRequest(BaseModel):
    """Payload to register a device push notification token."""
    token: str = Field(min_length=10, max_length=512)
    platform: str = Field(default="android", max_length=50)


class DeviceResponse(BaseModel):
    """Registered device response."""
    model_config = ConfigDict(from_attributes=True)

    id: str
    token: str
    platform: str
    is_active: bool
    created_at: datetime
