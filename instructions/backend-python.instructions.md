````instructions
---
applyTo: 
  - "**/*.py"
---
<python_standards>
## Python (FastAPI / Django / Flask)

- **Python 3.11+** with mandatory type hints on all functions/methods
- **Protocol classes** for dependency interfaces (duck typing with contracts)
- **Frozen dataclasses** for DTOs
- **Testing:** Pytest with pytest-cov
- **Linting:** Ruff or Black + isort + mypy

**Type Safety:** `strict: true` in mypy config. All functions must have return type annotations.

```python
# ❌ NEVER (SQL Injection)
query = f"SELECT * FROM users WHERE username = '{username}'"

# ✅ ALWAYS (Prepared statements)
query = "SELECT * FROM users WHERE username = %s"
cursor.execute(query, (username,))
```

See [examples/backend/python/](../examples/backend/python/) for UserService and test patterns.
See [examples/production/](../examples/production/) for Alembic migration patterns.
</python_standards>
````
