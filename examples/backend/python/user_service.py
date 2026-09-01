"""User service — domain-by-feature structure, typed boundaries, Protocol DI.

Pattern points:
- Protocol for the repository interface (duck typing with contracts)
- Frozen dataclasses for DTOs at the boundary
- Custom exception inheriting a project base, not bare Exception
- No SQL here — persistence is the repository's job (prepared statements there)
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Protocol


class ProjectError(Exception):
    """Base exception for the project. Custom exceptions inherit this."""


class UserNotFoundError(ProjectError):
    def __init__(self, user_id: int) -> None:
        super().__init__(f"user {user_id} not found")
        self.user_id = user_id


@dataclass(frozen=True)
class UserDTO:
    id: int
    username: str
    email: str


class UserRepository(Protocol):
    def get_by_id(self, user_id: int) -> UserDTO | None: ...

    def get_by_username(self, username: str) -> UserDTO | None: ...

    def insert(self, username: str, email: str) -> UserDTO: ...


class UserService:
    """Constructor injection of an abstraction — trivially testable."""

    def __init__(self, repository: UserRepository) -> None:
        self._repository = repository

    def get_user(self, user_id: int) -> UserDTO:
        user = self._repository.get_by_id(user_id)
        if user is None:
            raise UserNotFoundError(user_id)
        return user

    def register(self, username: str, email: str) -> UserDTO:
        # Validation at the service boundary; repository stays simple.
        if not username or len(username) > 64:
            raise ValueError("username must be 1-64 characters")
        if "@" not in email:
            raise ValueError("invalid email address")
        if self._repository.get_by_username(username) is not None:
            raise ValueError(f"username '{username}' already taken")
        return self._repository.insert(username, email)
