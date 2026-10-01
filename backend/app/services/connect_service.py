"""Peers, Groups, and Mentors discovery business logic service."""

import uuid
from typing import List, Optional
from fastapi import HTTPException, status
from sqlalchemy import func, or_, select
from sqlalchemy.orm import Session

from app.models.connection import Connection, ConnectionStatus
from app.models.group import Group, GroupMembership
from app.models.mentor import Mentor, MentorRequest, MentorRequestStatus
from app.models.user import User
from app.schemas.connection import ConnectionResponse
from app.schemas.group import GroupResponse
from app.schemas.mentor import MentorResponse


def toggle_connect_user(
    requester: User, target_user_id: uuid.UUID, db: Session
) -> str:
    """Toggle connecting with a peer student (Connect / Pending / Connected)."""
    if requester.id == target_user_id:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="You cannot connect with yourself.",
        )

    target_user = db.get(User, target_user_id)
    if not target_user or not target_user.is_active:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Target student user not found.",
        )

    stmt = select(Connection).where(
        or_(
            (Connection.requester_id == requester.id) & (Connection.receiver_id == target_user_id),
            (Connection.requester_id == target_user_id) & (Connection.receiver_id == requester.id),
        )
    )
    conn = db.execute(stmt).scalar_one_or_none()

    if not conn:
        new_conn = Connection(
            requester_id=requester.id,
            receiver_id=target_user_id,
            status=ConnectionStatus.PENDING,
        )
        db.add(new_conn)
        db.commit()
        return "Pending"
    elif conn.status == ConnectionStatus.PENDING:
        if conn.receiver_id == requester.id:
            # If target previously requested, accept it
            conn.status = ConnectionStatus.ACCEPTED
            db.commit()
            return "Connected"
        else:
            # Cancel pending request
            db.delete(conn)
            db.commit()
            return "Connect"
    elif conn.status == ConnectionStatus.ACCEPTED:
        # Disconnect
        db.delete(conn)
        db.commit()
        return "Connect"
    else:
        db.delete(conn)
        db.commit()
        return "Connect"


def list_connections(
    user: User, status_filter: Optional[ConnectionStatus], db: Session
) -> List[ConnectionResponse]:
    """List peer connections for the current user."""
    stmt = select(Connection).where(
        or_(Connection.requester_id == user.id, Connection.receiver_id == user.id)
    )
    if status_filter:
        stmt = stmt.where(Connection.status == status_filter)

    conns = db.execute(stmt).scalars().all()
    return [
        ConnectionResponse(
            id=str(c.id),
            requester_id=str(c.requester_id),
            receiver_id=str(c.receiver_id),
            status=c.status,
            created_at=c.created_at,
        )
        for c in conns
    ]


def list_groups(viewer: Optional[User], db: Session) -> List[GroupResponse]:
    """List student groups with membership status."""
    groups = db.execute(select(Group).order_by(Group.name.asc())).scalars().all()

    joined_ids = set()
    if viewer:
        memberships = db.execute(
            select(GroupMembership.group_id).where(GroupMembership.user_id == viewer.id)
        ).all()
        joined_ids = {str(m[0]) for m in memberships}

    return [
        GroupResponse(
            id=str(g.id),
            name=g.name,
            category=g.category,
            description=g.description,
            members_count=g.members_count,
            icon_name=g.icon_name,
            is_joined_by_current_user=str(g.id) in joined_ids,
            created_at=g.created_at,
        )
        for g in groups
    ]


def toggle_join_group(user: User, group_id: uuid.UUID, db: Session) -> bool:
    """Toggle joining or leaving a student interest group."""
    group = db.get(Group, group_id)
    if not group:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Group not found.",
        )

    stmt = select(GroupMembership).where(
        GroupMembership.group_id == group_id,
        GroupMembership.user_id == user.id,
    )
    membership = db.execute(stmt).scalar_one_or_none()

    if membership:
        db.delete(membership)
        group.members_count = max(0, group.members_count - 1)
        db.commit()
        return False  # Left group
    else:
        new_membership = GroupMembership(group_id=group_id, user_id=user.id)
        db.add(new_membership)
        group.members_count += 1
        db.commit()
        return True  # Joined group


def list_mentors(viewer: Optional[User], db: Session) -> List[MentorResponse]:
    """List faculty, alumni, and industry mentors."""
    mentors = db.execute(select(Mentor).order_by(Mentor.name.asc())).scalars().all()

    requested_ids = set()
    if viewer:
        requests = db.execute(
            select(MentorRequest.mentor_id).where(MentorRequest.user_id == viewer.id)
        ).all()
        requested_ids = {str(r[0]) for r in requests}

    return [
        MentorResponse(
            id=str(m.id),
            name=m.name,
            role=m.role,
            college=m.college,
            experience=m.experience,
            badge=m.badge,
            about=m.about,
            skills=m.skills or [],
            topics=m.topics or [],
            sessions=m.sessions or [],
            is_requested_by_current_user=str(m.id) in requested_ids,
            created_at=m.created_at,
        )
        for m in mentors
    ]


def request_mentor(user: User, mentor_id: uuid.UUID, db: Session) -> bool:
    """Toggle requesting mentorship from a mentor."""
    mentor = db.get(Mentor, mentor_id)
    if not mentor:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Mentor not found.",
        )

    stmt = select(MentorRequest).where(
        MentorRequest.mentor_id == mentor_id,
        MentorRequest.user_id == user.id,
    )
    req = db.execute(stmt).scalar_one_or_none()

    if req:
        db.delete(req)
        db.commit()
        return False  # Request cancelled
    else:
        new_req = MentorRequest(
            mentor_id=mentor_id,
            user_id=user.id,
            status=MentorRequestStatus.PENDING,
        )
        db.add(new_req)
        db.commit()
        return True  # Requested
