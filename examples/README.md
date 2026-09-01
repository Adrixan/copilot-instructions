# Examples

Working code demonstrations referenced by the instruction files. Each example is intentionally
small — it shows the pattern, not a complete application.

| Path | Demonstrates |
|------|--------------|
| `web/react/UserCard.tsx` + `.module.css` + `.test.tsx` | Theme-token component, semantic HTML, i18n, a11y, RTL + axe test |
| `web/react/useAsync.ts` + `.test.ts` | Typed async hook with abort/cleanup; Vitest hook test |
| `backend/python/` | Domain-structured Python service + pytest unit test |
| `backend/java/` | Record DTOs, constructor injection, JUnit 5 + Mockito + AssertJ |
| `backend/php/` | strict_types, readonly promotion, PHPUnit |
| `integration-tests/` | Testcontainers-based integration tests (Python, Java) |
| `production/jwt_auth_fastapi.py` | Argon2 hashing, short-expiry JWT, safe error responses |
| `production/alembic_migration_example.py` | Reversible Alembic migration |
| `production/prometheus.yml` | Metrics collection config |
| `docker/secure-dockerfile.md` | CIS-aligned multi-stage Dockerfile |
| `kubernetes/secure-deployment.md` | Restricted security context, limits, NetworkPolicy, PDB |
| `terraform/secure-config.md` | `for_each`, `prevent_destroy`, data sources |
| `ansible/secure-playbook.md` | Vault secrets, justified `become`, idempotent tasks |
| `ci/terraform-pipeline.yml` | Lint → Plan → Approve → Apply pipeline |
| `scripting/deploy.sh` + `test_deploy.bats` | Bash preamble spec + BATS test |
| `scripting/backup.ps1` + `backup.Tests.ps1` | PowerShell preamble spec + Pester test |
| `ops/pitfalls.md` | Cross-domain ops anti-patterns |
