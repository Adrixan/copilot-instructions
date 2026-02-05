# GitHub Copilot Instructions Collection

A comprehensive set of best practice instructions and examples to efficiently and securely develop across various architectures using GitHub Copilot.

## 📋 Overview

This repository provides domain-specific instruction files that guide GitHub Copilot to generate secure, maintainable, and high-quality code. Each instruction file targets specific technologies and includes concrete examples, security guidelines, and common pitfalls.

## 🎯 What's Inside

### Instruction Files

Located in [`instructions/`](instructions/), these files provide specialized guidance:

- **[ops.instructions.md](instructions/ops.instructions.md)** - DevOps & Infrastructure as Code
  - Docker, Kubernetes, Terraform, Ansible
  - Security-first configuration
  - GitOps workflows, CI/CD pipelines
  
- **[backend.instructions.md](instructions/backend.instructions.md)** - Backend Development
  - Java, PHP, Python, SQL
  - Dependency injection, type safety
  - TDD workflows, database security
  
- **[web.instructions.md](instructions/web.instructions.md)** - Frontend Development
  - React, TypeScript, HTML, CSS
  - Accessibility (WCAG 2.1 AA)
  - Internationalization (i18n)
  - XSS prevention, CSP policies
  
- **[scripting.instructions.md](instructions/scripting.instructions.md)** - Shell Scripting
  - Bash and PowerShell automation
  - Error handling, idempotency
  - Security best practices

### Working Examples

Located in [`examples/`](examples/), real-world code demonstrations:

#### DevOps Examples
- [`examples/docker/secure-dockerfile.md`](examples/docker/secure-dockerfile.md) - Multi-stage builds, security scanning
- [`examples/terraform/secure-config.md`](examples/terraform/secure-config.md) - State management, secrets handling
- [`examples/kubernetes/secure-deployment.md`](examples/kubernetes/secure-deployment.md) - RBAC, NetworkPolicy, security contexts
- [`examples/ansible/secure-playbook.md`](examples/ansible/secure-playbook.md) - Vault integration, idempotency
- [`examples/ci/terraform-pipeline.yml`](examples/ci/terraform-pipeline.yml) - GitHub Actions with OIDC

#### Backend Examples
- [`examples/backend/python/user_service.py`](examples/backend/python/user_service.py) - FastAPI with type hints, DI
- [`examples/backend/python/test_user_service.py`](examples/backend/python/test_user_service.py) - pytest with fixtures
- [`examples/backend/java/UserService.java`](examples/backend/java/UserService.java) - Spring Boot with Records
- [`examples/backend/java/UserServiceTest.java`](examples/backend/java/UserServiceTest.java) - JUnit 5 with AssertJ
- [`examples/backend/php/UserService.php`](examples/backend/php/UserService.php) - PHP 8+ with strict types, readonly properties
- [`examples/backend/php/UserServiceTest.php`](examples/backend/php/UserServiceTest.php) - PHPUnit 10 with attributes

#### Integration Testing
- [`examples/integration-tests/test_user_service_integration.py`](examples/integration-tests/test_user_service_integration.py) - Python + Testcontainers + PostgreSQL
- [`examples/integration-tests/UserServiceIntegrationTest.java`](examples/integration-tests/UserServiceIntegrationTest.java) - Spring Boot + Testcontainers

#### Production Patterns
- [`examples/production/alembic_setup.py`](examples/production/alembic_setup.py) - Database migration configuration
- [`examples/production/001_create_users_table.py`](examples/production/001_create_users_table.py) - Schema migration
- [`examples/production/002_add_user_preferences.py`](examples/production/002_add_user_preferences.py) - Data migration
- [`examples/production/jwt_auth_fastapi.py`](examples/production/jwt_auth_fastapi.py) - JWT authentication with FastAPI
- [`examples/production/prometheus.yml`](examples/production/prometheus.yml) - Monitoring and alerting

#### Frontend Examples
- [`examples/web/react/UserCard.tsx`](examples/web/react/UserCard.tsx) - Accessible React component
- [`examples/web/react/UserCard.test.tsx`](examples/web/react/UserCard.test.tsx) - Testing Library + axe
- [`examples/web/react/useAsync.ts`](examples/web/react/useAsync.ts) - Custom hook for async operations
- [`examples/web/react/useAsync.test.ts`](examples/web/react/useAsync.test.ts) - Hook testing patterns
- [`examples/web/react/UserCard.module.css`](examples/web/react/UserCard.module.css) - CSS modules with accessibility

- [`examples/scripting/test_deploy.bats`](examples/scripting/test_deploy.bats) - BATS tests for Bash scripts
- [`examples/scripting/backup.Tests.ps1`](examples/scripting/backup.Tests.ps1) - Pester tests for PowerShell
#### Scripting Examples
- [`examples/scripting/deploy.sh`](examples/scripting/deploy.sh) - Production deployment script
- [`examples/scripting/backup.ps1`](examples/scripting/backup.ps1) - PowerShell backup automation

## 🚀 Quick Start

### Option A: As a Git Submodule (Recommended)

Using this repository as a git submodule allows you to:
- Keep instructions updated with upstream changes
- Maintain consistent practices across multiple projects
- Version control which instruction set version your project uses

**📖 See [SUBMODULE_GUIDE.md](SUBMODULE_GUIDE.md) for comprehensive setup and team workflows.**

#### Adding to a New or Existing Project

```bash
# Navigate to your project root
cd /path/to/your/project

# Add as submodule in .github directory
git submodule add https://github.com/yourusername/copilot-instructions.git .github/copilot-instructions

# Create a symlink to the main orchestrator (optional but recommended)
ln -s copilot-instructions/copilot-instructions.md .github/copilot-instructions.md

# Commit the submodule
git add .gitmodules .github/copilot-instructions .github/copilot-instructions.md
git commit -m "Add Copilot instructions as submodule"
```

#### Cloning a Project with This Submodule

```bash
# Option 1: Clone with submodules in one command
git clone --recursive https://github.com/yourorg/your-project.git

# Option 2: Clone then initialize submodules
git clone https://github.com/yourorg/your-project.git
cd your-project
git submodule init
git submodule update
```

#### Updating Submodule to Latest Version

```bash
# Update to latest commit on default branch
cd .github/copilot-instructions
git pull origin main
cd ../..
git add .github/copilot-instructions
git commit -m "Update Copilot instructions to latest version"

# Or update all submodules from project root
git submodule update --remote --merge
```

#### Using a Specific Version

```bash
# Navigate to submodule
cd .github/copilot-instructions

# Checkout specific version/tag
git checkout v1.2.0

# Return to project root and commit
cd ../..
git add .github/copilot-instructions
git commit -m "Pin Copilot instructions to v1.2.0"
```

### Option B: Direct Copy

If you prefer a static copy that won't change:

```bash
# Clone this repository
git clone https://github.com/yourusername/copilot-instructions.git

# Copy to your project
cp copilot-instructions/copilot-instructions.md /your/project/.github/
cp -r copilot-instructions/instructions /your/project/.github/
cp -r copilot-instructions/examples /your/project/.github/

# Commit to your project
cd /your/project
git add .github/
git commit -m "Add Copilot instructions"
```

### 2. Usage with GitHub Copilot

GitHub Copilot automatically loads `.github/copilot-instructions.md` in your workspace. The orchestrator file will:

1. **Detect file type** - Matches files against `applyTo` patterns
2. **Load relevant instructions** - Applies domain-specific guidelines
3. **Reference examples** - Uses working code as templates
4. **Generate code** - Following best practices and security standards

**For Submodule Users:**
- If you used the symlink approach (Option A), Copilot will automatically find the instructions
- The submodule structure keeps all files self-contained with relative paths
- Examples and instruction files reference each other correctly regardless of installation method

### 3. Customize for Your Project

Edit `copilot-instructions.md` to:
- Add project-specific conventions
- Reference internal libraries
- Define team standards
- Include architectural decisions

## � Git Submodule Best Practices

### Path Considerations

**All paths in this repository are relative**, making it safe to use as a submodule:
- ✅ Instruction files reference examples: `../examples/backend/`
- ✅ Orchestrator references instructions: `instructions/backend.instructions.md`
- ✅ Examples cross-reference: `../ci/terraform-pipeline.yml`

**Symlink Setup (Recommended)**:
```bash
# Create symlink so Copilot finds the main file automatically
cd .github
ln -s copilot-instructions/copilot-instructions.md copilot-instructions.md
```

This creates a structure like:
```
your-project/
├── .github/
│   ├── copilot-instructions/          # Submodule
│   │   ├── copilot-instructions.md
│   │   ├── instructions/
│   │   └── examples/
│   └── copilot-instructions.md        # Symlink → copilot-instructions/copilot-instructions.md
└── src/
```

### Team Workflow

**For Organizations:**

1. **Fork this repository** to your organization
2. **Customize** with your team's standards
3. **Tag releases** for version control (v1.0.0, v1.1.0, etc.)
4. **Add as submodule** to all team projects

```bash
# Use your fork
git submodule add https://github.com/yourorg/copilot-instructions.git .github/copilot-instructions

# Pin to specific version
cd .github/copilot-instructions
git checkout v1.0.0
```

**Keeping Projects in Sync:**

```bash
# Create a script to update all projects
# update-copilot-instructions.sh
#!/bin/bash
PROJECTS=(
    "project-a"
    "project-b"
    "project-c"
)

for project in "${PROJECTS[@]}"; do
    echo "Updating $project..."
    cd "$project"
    git submodule update --remote .github/copilot-instructions
    git add .github/copilot-instructions
    git commit -m "Update Copilot instructions"
    git push
    cd ..
done
```

### Troubleshooting Submodules

**Submodule not initialized:**
```bash
git submodule init
git submodule update
```

**Detached HEAD state in submodule:**
```bash
cd .github/copilot-instructions
git checkout main
cd ../..
```

**Remove submodule:**
```bash
# Remove from git
git submodule deinit .github/copilot-instructions
git rm .github/copilot-instructions
rm -rf .git/modules/.github/copilot-instructions

# Commit
git commit -m "Remove Copilot instructions submodule"
```

**Submodule conflicts during merge:**
```bash
# Accept theirs
git checkout --theirs .github/copilot-instructions
git add .github/copilot-instructions

# Or accept ours
git checkout --ours .github/copilot-instructions
git add .github/copilot-instructions
```

## �📖 Key Features

### Security by Default

All instructions prioritize security:

- ❌ **Docker**: Never run as root, scan for vulnerabilities
- ❌ **Kubernetes**: Network policies, security contexts, RBAC
- ❌ **Terraform**: Encrypted state, secret rotation
- ❌ **SQL**: Prepared statements, input validation
- ❌ **Web**: Content Security Policy, XSS prevention

### Code Quality Standards

- **Type Safety**: TypeScript strict mode, Python type hints, Java Records
- **Testing**: TDD workflows, mocking patterns, accessibility tests
- **Error Handling**: Explicit error types, graceful degradation
- **Documentation**: JSDoc, docstrings, inline comments

### Common Pitfalls

Each instruction file includes a "Common Pitfalls" section with:
- ❌ Anti-patterns to avoid
- ✅ Recommended alternatives
- Real-world examples

## 🎓 Learn from Examples

Each example file demonstrates:

1. **Best Practices** - Industry-standard patterns
2. **Security** - Vulnerability prevention
3. **Testing** - Comprehensive test coverage
4. **Documentation** - Clear inline comments

### Example Workflow

```bash
# Working on a Python service?
# 1. Open examples/backend/python/user_service.py
# 2. See dependency injection, type hints, validation
# 3. Check test_user_service.py for testing patterns
# 4. Use as template for your code

# Deploying with Terraform?
# 1. Review examples/terraform/secure-config.md
# 2. See remote state, secret management
# 3. Check examples/ci/terraform-pipeline.yml for CI/CD
# 4. Apply to your infrastructure
```

## 📁 Repository Structure

```
copilot-instructions/
├── copilot-instructions.md          # Main orchestrator
├── .gitmodules.example               # Example submodule configuration
├── README.md                          # This file
├── instructions/
│   ├── ops.instructions.md           # DevOps & IaC
│   ├── backend.instructions.md       # Backend development
│   ├── web.instructions.md           # Frontend development
│   └── scripting.instructions.md     # Shell scripting
├── examples/
│   ├── docker/
│   │   └── secure-dockerfile.md
│   ├── terraform/
│   │   └── secure-config.md
│   ├── kubernetes/
│   │   └── secure-deployment.md
│   ├── ansible/
│   │   └── secure-playbook.md
│   ├── ops/
│   │   └── pitfalls.md
│   ├── ci/
│   │   └── terraform-pipeline.yml
│   ├── backend/
│   │   ├── python/
│   │   │   ├── user_service.py
│   │   │   └── test_user_service.py
│   │   └── java/
│   │       ├── UserService.java
│   │       └── UserServiceTest.java
│   ├── web/
│   │   └── react/
│   │       ├── UserCard.tsx
│   │       └── UserCard.test.tsx
│   └── scripting/
│       ├── deploy.sh
│       └── backup.ps1
└── LICENSE
```

## 🔧 Advanced Usage

### Git Submodule Configuration

For detailed submodule setup, team workflows, CI/CD integration, and troubleshooting:
- 📖 **[Complete Submodule Guide](SUBMODULE_GUIDE.md)** - Comprehensive documentation
- 📝 **[.gitmodules.example](.gitmodules.example)** - Configuration templates

### Environment-Specific Instructions

Create environment-specific versions:

```bash
# Development
.github/copilot-instructions.dev.md

# Production
.github/copilot-instructions.prod.md
```

### Project Templates

Use as a template for new projects:

```bash
# Create new project with instructions
cookiecutter https://github.com/yourusername/copilot-instructions.git
```

### Team Collaboration

1. **Fork this repository** for your organization
2. **Add team conventions** in a dedicated section
3. **Create PR workflows** to review instruction changes
4. **Share examples** from your projects

## 🤝 Contributing

Contributions welcome! To add new examples or improve instructions:

### For Direct Contributors

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/new-example`)
3. Add your example with comprehensive comments
4. Include tests demonstrating best practices
5. Update relevant instruction file
6. Ensure all paths remain relative (for submodule compatibility)
7. Submit a Pull Request

### For Organizations Using as Submodule

If you've forked this repo for your organization:

1. **Make changes in your fork** with team-specific customizations
2. **Keep upstream in sync** to get community improvements:
   ```bash
   # Add upstream remote (one-time)
   git remote add upstream https://github.com/original/copilot-instructions.git
   
   # Fetch and merge upstream changes
   git fetch upstream
   git merge upstream/main
   
   # Or rebase your changes on top
   git rebase upstream/main
   ```
3. **Tag releases** for version control:
   ```bash
   git tag -a v1.0.0 -m "Release version 1.0.0"
   git push origin v1.0.0
   ```
4. **Consider contributing** improvements back to the main repository

### Contribution Guidelines

- **Code Quality**: Follow existing patterns
- **Security**: Prioritize security in all examples
- **Documentation**: Add clear explanations
- **Testing**: Include test coverage
- **Real-World**: Use practical, production-ready examples
- **Paths**: Keep all paths relative for submodule compatibility
- **No Absolute Paths**: Avoid hardcoded absolute paths in examples

## 📝 License

MIT License - see [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

Built with best practices from:
- OWASP Security Guidelines
- CIS Benchmarks
- Cloud Native Foundation
- WCAG Accessibility Standards
- Industry-standard linting tools

## 🔗 Resources

- [GitHub Copilot Documentation](https://docs.github.com/en/copilot)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [CIS Benchmarks](https://www.cisecurity.org/cis-benchmarks/)
- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)

---

**Made with ❤️ for better, safer code generation**
