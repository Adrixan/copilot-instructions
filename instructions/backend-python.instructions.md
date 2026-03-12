---
applyTo: 
  - "**/*.py"
---
<python_standards>

## Python (FastAPI / Django / Flask)

- **Python 3.12+** with mandatory type hints on all functions/methods
- **`type` statement** for type aliases (Python 3.12+): `type UserId = int`
- **`@override` decorator** from `typing` for explicit method overrides
- **Protocol classes** for dependency interfaces (duck typing with contracts)
- **Frozen dataclasses** or **`NamedTuple`** for DTOs
- **Testing:** Pytest with pytest-cov
- **Linting:** Ruff (replaces Black + isort + flake8) + mypy
- **SAST:** Semgrep or Bandit in CI

**Project Structure:** Packages organized by domain, not by type. No `utils.py` or `helpers.py` catch-all modules. `src/` layout with `pyproject.toml` from day one. Every project has `pyproject.toml` at start — not added later when packaging becomes necessary.

```text
src/project_name/
  user/service.py, repository.py, models.py
  order/service.py, repository.py
  core/config.py, exceptions.py
```

**Type Safety:** `strict: true` in mypy config.
All functions must have return type annotations including `-> None`.
Use `TypeGuard` and `TypeIs` for type narrowing. `Any` forbidden unless interfacing with untyped third-party library (requires inline comment).

**Error Handling:** Custom exceptions inherit from a project-level base exception, not directly from `Exception`. `except Exception` without re-raising forbidden unless at a top-level boundary (CLI entry, API handler) — every broad catch requires comment. Never use exceptions for control flow.

**Dependency Management:** Dependencies pinned in `pyproject.toml` with version constraints. Virtual environments mandatory — never install into system Python. Dev dependencies separated from production. Tool choice (pip+venv, poetry, uv, pdm) made at project start and logged.

**Async:** One async framework per project (`asyncio` default). `async def` with no `await` = remove the `async`. Never call `asyncio.run()` inside running async code. Blocking calls in async functions must use `asyncio.to_thread()`.

```python
# ❌ NEVER (SQL Injection)
query = f"SELECT * FROM users WHERE username = '{username}'"

# ✅ ALWAYS (Prepared statements)
query = "SELECT * FROM users WHERE username = %s"
cursor.execute(query, (username,))
```

**Observability:** Use OpenTelemetry SDK for traces/metrics. Structured logging via `structlog` or `python-json-logger`.

See [examples/backend/python/](../examples/backend/python/) for UserService and test patterns.
See [examples/production/](../examples/production/) for Alembic migration patterns.
</python_standards>
