````instructions
---
applyTo: 
  - "**/*.sql"
---
<sql_standards>
## SQL

- **ANSI SQL** preferred for portability
- **Migrations ONLY** for schema changes (Flyway, Liquibase, Alembic)
- **Indexes** on Foreign Keys, WHERE/JOIN/ORDER BY columns automatically
- **Naming:** `snake_case` for all identifiers

```sql
-- ❌ NEVER (SQL Injection via string concatenation in app code)
-- ✅ ALWAYS use prepared statements / parameterized queries in app code
```

**Query Optimization:** Use EXPLAIN for slow queries, eager loading to prevent N+1, cursor-based pagination for large datasets.

See [examples/production/](../examples/production/) for Alembic migration patterns.
</sql_standards>
````
