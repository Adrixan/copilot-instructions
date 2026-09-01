"""Unit tests for UserService — no database, no Spring/context loading.

Uses an in-memory fake repository implementing the Protocol.
Run: pytest -q
"""

from __future__ import annotations

import pytest

from user_service import UserDTO, UserNotFoundError, UserService


class FakeUserRepository:
    def __init__(self) -> None:
        self._users: dict[int, UserDTO] = {}
        self._next_id = 1

    def get_by_id(self, user_id: int) -> UserDTO | None:
        return self._users.get(user_id)

    def get_by_username(self, username: str) -> UserDTO | None:
        return next((u for u in self._users.values() if u.username == username), None)

    def insert(self, username: str, email: str) -> UserDTO:
        user = UserDTO(id=self._next_id, username=username, email=email)
        self._users[user.id] = user
        self._next_id += 1
        return user


@pytest.fixture
def service() -> UserService:
    return UserService(FakeUserRepository())


def test_register_creates_user(service: UserService) -> None:
    user = service.register("ada", "ada@example.com")
    assert user.username == "ada"
    assert user.id == 1


def test_register_rejects_duplicate_username(service: UserService) -> None:
    service.register("ada", "ada@example.com")
    with pytest.raises(ValueError, match="already taken"):
        service.register("ada", "other@example.com")


def test_register_rejects_invalid_email(service: UserService) -> None:
    with pytest.raises(ValueError, match="invalid email"):
        service.register("ada", "not-an-email")


def test_get_user_raises_typed_error_when_missing(service: UserService) -> None:
    with pytest.raises(UserNotFoundError) as excinfo:
        service.get_user(999)
    assert excinfo.value.user_id == 999


def test_get_user_returns_registered_user(service: UserService) -> None:
    created = service.register("ada", "ada@example.com")
    assert service.get_user(created.id) == created
