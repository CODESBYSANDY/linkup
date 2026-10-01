"""Peer connection schemas."""

from datetime import datetime
from pydantic import BaseModel, ConfigDict
from app.models.connection import ConnectionStatus


class ConnectionResponse(BaseModel):
    """Peer connection response."""
    model_config = ConfigDict(from_attributes=True)

    id: str
    requester_id: str
    receiver_id: str
    status: ConnectionStatus
    created_at: datetime


class ConnectionStatusUpdate(BaseModel):
    """Payload to accept/reject/block connection."""
    status: ConnectionStatus
