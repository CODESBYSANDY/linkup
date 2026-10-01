"""Firebase Admin SDK initialization and ID token verification."""

import json
import os
from typing import Any, Dict, Optional
import firebase_admin
from firebase_admin import auth, credentials
from fastapi import HTTPException, status
from app.core.config import settings
from app.core.logging import logger

_firebase_app: Optional[firebase_admin.App] = None


def initialize_firebase() -> Optional[firebase_admin.App]:
    """Initialize Firebase Admin SDK using service account credentials."""
    global _firebase_app
    if _firebase_app is not None:
        return _firebase_app

    if firebase_admin._apps:
        _firebase_app = firebase_admin.get_app()
        return _firebase_app

    try:
        # 1. Direct JSON string from environment variable
        if settings.FIREBASE_SERVICE_ACCOUNT_JSON:
            cert_dict = json.loads(settings.FIREBASE_SERVICE_ACCOUNT_JSON)
            cred = credentials.Certificate(cert_dict)
            _firebase_app = firebase_admin.initialize_app(cred)
            logger.info("Firebase Admin initialized from FIREBASE_SERVICE_ACCOUNT_JSON environment variable.")
            return _firebase_app

        # 2. File path from configuration
        if settings.FIREBASE_CREDENTIALS_PATH and os.path.isfile(settings.FIREBASE_CREDENTIALS_PATH):
            cred = credentials.Certificate(settings.FIREBASE_CREDENTIALS_PATH)
            _firebase_app = firebase_admin.initialize_app(cred)
            logger.info("Firebase Admin initialized from credentials file: %s", settings.FIREBASE_CREDENTIALS_PATH)
            return _firebase_app

        # 3. Fallback: Project ID default
        if settings.FIREBASE_PROJECT_ID:
            _firebase_app = firebase_admin.initialize_app(options={"projectId": settings.FIREBASE_PROJECT_ID})
            logger.warning("Firebase Admin initialized with project ID only (no service account).")
            return _firebase_app

        logger.warning("No Firebase credentials provided. Token verification will fail in production.")
        return None
    except Exception as exc:
        logger.error("Failed to initialize Firebase Admin SDK: %s", exc)
        return None


def verify_firebase_id_token(id_token: str) -> Dict[str, Any]:
    """Verify incoming Firebase JWT ID Token and return decoded claims."""
    # Ensure Firebase app is initialized
    initialize_firebase()

    # Test mode bypass for deterministic automated testing
    if settings.TESTING and id_token.startswith("test_token_"):
        uid = id_token.replace("test_token_", "")
        return {
            "uid": uid,
            "email": f"{uid}@student.linkup.dev",
            "name": uid.replace("_", " ").title(),
            "picture": None,
        }

    try:
        decoded_token = auth.verify_id_token(id_token, check_revoked=False)
        return decoded_token
    except auth.ExpiredIdTokenError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Firebase ID token has expired. Please refresh your session.",
            headers={"WWW-Authenticate": "Bearer"},
        )
    except auth.RevokedIdTokenError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Firebase ID token has been revoked.",
            headers={"WWW-Authenticate": "Bearer"},
        )
    except (auth.InvalidIdTokenError, auth.CertificateFetchError, ValueError) as exc:
        logger.warning("Token verification failed: %s", exc)
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid authentication token.",
            headers={"WWW-Authenticate": "Bearer"},
        )
    except Exception as exc:
        logger.error("Unexpected error during Firebase token verification: %s", exc)
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Authentication verification failed.",
            headers={"WWW-Authenticate": "Bearer"},
        )
