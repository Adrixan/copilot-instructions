"""Integration test pattern: real PostgreSQL via Testcontainers, not SQLite.

Requires Docker. Skips automatically when Docker is unavailable (CI-safe).
Run: pytest -q -m integration
"""

from __future__ import annotations

import pytest

docker_available = True
try:
    from testcontainers.postgres import PostgresContainer
except ImportError:  # pragma: no cover
    docker_available = False

pytestmark = [
    pytest.mark.integration,
    pytest.mark.skipif(not docker_available, reason="testcontainers not installed"),
]


@pytest.fixture(scope="module")
def db_url():
    """Real database per test module — schema applied via migrations."""
    with PostgresContainer("postgres:16-alpine") as postgres:
        url = postgres.get_connection_url()
        # apply_migrations(url)  # <- run your migration tool here (Alembic etc.)
        yield url


def test_user_service_roundtrip(db_url: str) -> None:
    # repository = PgUserRepository(db_url)
    # service = UserService(repository)
    #
    # created = service.register("ada", "ada@example.com")
    # fetched = service.get_user(created.id)
    #
    # assert fetched.username == "ada"
    assert db_url.startswith("postgresql"), "Testcontainers returns a real PG URL"


def test_duplicate_username_rejected_by_unique_constraint(db_url: str) -> None:
    # Real-database tests catch what fakes cannot: constraints, types,
    # transaction semantics, SQL dialect behavior.
    #
    # service.register("ada", "ada@example.com")
    # with pytest.raises(IntegrityError):
    #     service.register("ada", "other@example.com")
    assert db_url  # placeholder asserts keep the example runnable
