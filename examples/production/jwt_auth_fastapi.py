"""Auth pattern: Argon2 password hashing, short-expiry JWT, safe errors.

Deps: fastapi, argon2-cffi, pyjwt
"""

from __future__ import annotations

import os
import secrets
from datetime import datetime, timedelta, timezone

import jwt
from argon2 import PasswordHasher
from argon2.exceptions import VerifyMismatchError
from fastapi import Depends, FastAPI, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer

# Secrets from environment — never hardcoded, never committed.
SECRET_KEY = os.environ["JWT_SECRET_KEY"]
ACCESS_TOKEN_TTL = timedelta(minutes=15)  # short-lived access token
REFRESH_TOKEN_TTL = timedelta(days=7)
ALGORITHM = "HS256"

hasher = PasswordHasher()  # Argon2id with safe defaults
bearer = HTTPBearer(auto_error=False)
app = FastAPI()


def hash_password(password: str) -> str:
    return hasher.hash(password)


def verify_password(password: str, hashed: str) -> bool:
    try:
        return hasher.verify(hashed, password)
    except VerifyMismatchError:
        return False


def issue_token(subject: str, ttl: timedelta, token_type: str) -> str:
    now = datetime.now(timezone.utc)
    payload = {
        "sub": subject,
        "type": token_type,
        "iat": now,
        "exp": now + ttl,
        "jti": secrets.token_urlsafe(16),  # unique id — enables revocation
    }
    return jwt.encode(payload, SECRET_KEY, algorithm=ALGORITHM)


def require_access_token(
    credentials: HTTPAuthorizationCredentials | None = Depends(bearer),
) -> dict:
    if credentials is None:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Missing token")
    try:
        payload = jwt.decode(credentials.credentials, SECRET_KEY, algorithms=[ALGORITHM])
    except jwt.PyJWTError:
        # Safe generic message — never leak WHY validation failed in detail.
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Invalid or expired token")
    if payload.get("type") != "access":
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Invalid token type")
    return payload


@app.post("/auth/login")
def login(username: str, password: str) -> dict:
    # user = users.get_by_username(username) — repository lookup
    # if user is None or not verify_password(password, user.password_hash):
    #     raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Invalid credentials")
    #
    # Identical error for unknown user and wrong password — no user enumeration.
    # Rate limiting belongs on this endpoint (see OWASP A07 guidance).
    if not username or not password:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Invalid credentials")
    return {
        "access_token": issue_token(username, ACCESS_TOKEN_TTL, "access"),
        "refresh_token": issue_token(username, REFRESH_TOKEN_TTL, "refresh"),
        "token_type": "bearer",
    }


@app.get("/me")
def me(token: dict = Depends(require_access_token)) -> dict:
    return {"sub": token["sub"]}
