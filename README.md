# GitHub Copilot Instructions Collection

A comprehensive set of best practice instructions and examples to efficiently and securely develop across various architectures using GitHub Copilot.

## Overview

Domain-specific instruction files that guide GitHub Copilot to generate secure, maintainable, and high-quality code. Each file targets specific technologies with security guidelines, testing standards, and common pitfalls.

## Instruction Files

Located in [`instructions/`](instructions/):

| File | Domain | Technologies |
|------|--------|-------------|
| [ops.instructions.md](instructions/ops.instructions.md) | DevOps & IaC | Docker, Kubernetes, Terraform, Ansible |
| [backend.instructions.md](instructions/backend.instructions.md) | Backend | Java, PHP, Python, SQL |
| [web.instructions.md](instructions/web.instructions.md) | Frontend | React, TypeScript, HTML, CSS |
| [scripting.instructions.md](instructions/scripting.instructions.md) | Scripting | Bash, PowerShell |

## Working Examples

Located in [`examples/`](examples/):

| Category | Files |
|----------|-------|
| **Backend** | [Python](examples/backend/python/), [Java](examples/backend/java/), [PHP](examples/backend/php/) — UserService + tests |
| **Integration Tests** | [Python + Testcontainers](examples/integration-tests/test_user_service_integration.py), [Spring Boot + Testcontainers](examples/integration-tests/UserServiceIntegrationTest.java) |
| **Production Patterns** | [Alembic migrations](examples/production/), [JWT auth](examples/production/jwt_auth_fastapi.py), [Prometheus](examples/production/prometheus.yml) |
| **Frontend** | [React components](examples/web/react/) — UserCard, useAsync hook, CSS modules, tests |
| **DevOps** | [Docker](examples/docker/), [Terraform](examples/terraform/), [Kubernetes](examples/kubernetes/), [Ansible](examples/ansible/), [CI/CD](examples/ci/) |
| **Scripting** | [Bash deploy](examples/scripting/deploy.sh) + [BATS tests](examples/scripting/test_deploy.bats), [PowerShell backup](examples/scripting/backup.ps1) + [Pester tests](examples/scripting/backup.Tests.ps1) |

## Quick Start

### Option A: Git Submodule (Recommended)

```bash
cd /path/to/your/project
git submodule add https://github.com/yourusername/copilot-instructions.git .github/copilot-instructions
ln -s copilot-instructions/copilot-instructions.md .github/copilot-instructions.md
git add .gitmodules .github/
git commit -m "Add Copilot instructions as submodule"
```

**See [SUBMODULE_GUIDE.md](SUBMODULE_GUIDE.md) for team workflows, CI/CD integration, updating, and troubleshooting.**

### Option B: Direct Copy

```bash
cp copilot-instructions.md /your/project/.github/
cp -r instructions /your/project/.github/
cp -r examples /your/project/.github/
```

### How It Works

GitHub Copilot automatically loads `.github/copilot-instructions.md`. The orchestrator detects file types via `applyTo` patterns and loads domain-specific guidelines. All paths are relative for submodule compatibility.

### Customize for Your Project

Edit `copilot-instructions.md` to add project-specific conventions, internal library references, team standards, and architectural decisions.

## Key Features

- **Security by Default:** OWASP, CIS benchmarks, no hardcoded secrets, input validation, CSP
- **TDD Workflow:** Test-first for business logic, linting/validation for infrastructure
- **Type Safety:** TypeScript strict mode, Python type hints, Java Records, PHP strict types
- **Accessibility:** WCAG 2.1 AA, semantic HTML, ARIA, keyboard navigation
- **i18n:** Mandatory translation keys, locale-aware formatting
- **Common Pitfalls:** Anti-patterns with corrections in every instruction file

## Repository Structure

```
copilot-instructions/
├── copilot-instructions.md      # Main orchestrator
├── instructions/
│   ├── ops.instructions.md      # DevOps & IaC
│   ├── backend.instructions.md  # Backend development
│   ├── web.instructions.md      # Frontend development
│   └── scripting.instructions.md # Shell scripting
├── examples/                    # Working code demonstrations
│   ├── backend/                 # Java, PHP, Python
│   ├── web/react/               # React components + tests
│   ├── docker/                  # Secure Dockerfiles
│   ├── terraform/               # State & secrets management
│   ├── kubernetes/              # RBAC, NetworkPolicy
│   ├── ansible/                 # Vault, idempotency
│   ├── ci/                      # GitHub Actions pipelines
│   ├── production/              # Migrations, auth, monitoring
│   ├── scripting/               # Bash + PowerShell + tests
│   └── ops/                     # Cross-domain pitfalls
├── SUBMODULE_GUIDE.md           # Git submodule integration
├── README.md
└── LICENSE
```

## Contributing

1. Fork → feature branch → add example with comments and tests → update instruction file → PR
2. Keep all paths relative (submodule compatibility)
3. Follow existing patterns: security-first, tested, documented

**For organizations:** Fork, customize, tag releases, add as submodule to team projects. Sync upstream with `git fetch upstream && git merge upstream/main`.

## License

GNU Affero General Public License v3 — see [LICENSE](LICENSE).

## Resources

- [GitHub Copilot Documentation](https://docs.github.com/en/copilot)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
