# GitHub Copilot Instructions Collection

A comprehensive set of best practice instructions to efficiently
and securely develop across various architectures using GitHub Copilot, Gemini, and Antigravity agents.

## Overview

Domain-specific instruction files that strictly govern the behavior of automated coding agents (like GitHub Copilot, Gemini, and Antigravity) to generate secure, maintainable, and high-quality code. These files enforce strict Agile and TDD methodologies, mandate user-profiling, and set explicit constraints to prevent common AI failure modes such as silent scope reduction, context loss, brute-force debugging, and code recklessness. Each file targets specific technologies and sets unwavering baseline rules for security guidelines, accessibility, testing standards, and continuous documentation.

The orchestrator (`copilot-instructions.md`) includes built-in **behavioral discipline rules**
that address common AI failure modes: context loss, silent scope reduction, over-agreement,
brute-force debugging, code recklessness, test avoidance, and generic design defaults.
and integrated into the existing Agile/TDD workflow.

## Instruction Files

Located in [`instructions/`](instructions/). Files are split by language/tool
so only relevant instructions are loaded per file type, minimizing context window usage:

| File | Domain | applyTo |
| ------ | -------- | --------- |
| [backend-shared](instructions/backend-shared.instructions.md) | Backend (all) | `*.py`, `*.java`, `*.go`, `*.php`, `*.sql` |
| [backend-python](instructions/backend-python.instructions.md) | Python 3.12+ | `*.py` |
| [backend-java](instructions/backend-java.instructions.md) | Java 21 / Spring Boot 3.3+ | `*.java` |
| [backend-go](instructions/backend-go.instructions.md) | Go 1.22+ | `*.go`, `go.mod`, `go.sum` |
| [backend-php](instructions/backend-php.instructions.md) | PHP 8.3+ / Laravel 11 / Symfony 7 | `*.php` |
| [backend-dotnet](instructions/backend-dotnet.instructions.md) | .NET / C# (ASP.NET Core) | `*.cs`, `*.csproj`, `*.sln`, `*.razor` |
| [backend-rust](instructions/backend-rust.instructions.md) | Rust | `*.rs`, `Cargo.toml`, `Cargo.lock` |
| [backend-sql](instructions/backend-sql.instructions.md) | SQL | `*.sql` |
| [ai-integration](instructions/ai-integration.instructions.md) | AI/ML Integration | `*.py`, `*.ts`, `*.js`, `*.java` |
| [ops-shared](instructions/ops-shared.instructions.md) | DevOps (all) | Dockerfiles, infra YAML, `*.tf`, `*.hcl` |
| [ops-docker](instructions/ops-docker.instructions.md) | Docker / Podman | `Dockerfile*`, `Containerfile*`, `docker-compose*` |
| [ops-kubernetes](instructions/ops-kubernetes.instructions.md) | Kubernetes | `k8s/**`, `kubernetes/**`, `helm/**` |
| [ops-terraform](instructions/ops-terraform.instructions.md) | Terraform 1.7+ / OpenTofu | `*.tf`, `*.tfvars`, `*.hcl` |
| [ops-ansible](instructions/ops-ansible.instructions.md) | Ansible | `ansible/**`, `playbooks/**` |
| [scripting-shared](instructions/scripting-shared.instructions.md) | Scripting (all) | `*.sh`, `*.ps1` |
| [scripting-bash](instructions/scripting-bash.instructions.md) | Bash | `*.sh` |
| [scripting-powershell](instructions/scripting-powershell.instructions.md) | PowerShell | `*.ps1` |
| [web](instructions/web.instructions.md) | Frontend (React 19 / Next.js 15 / TS 5.6+) | `*.html`, `*.css`, `*.js`, `*.ts`, `*.jsx`, `*.tsx` |
| [mobile-swift](instructions/mobile-swift.instructions.md) | Swift / SwiftUI (iOS/macOS) | `*.swift`, `Package.swift`, `*.xcodeproj` |
| [mobile-kotlin](instructions/mobile-kotlin.instructions.md) | Kotlin / Android / Compose | `*.kt`, `*.kts`, `build.gradle*` |
| [mobile-flutter](instructions/mobile-flutter.instructions.md) | Flutter / Dart | `*.dart`, `pubspec.yaml` |

## Quick Start

You can either copy the files directly into your project or integrate this repository as a Git submodule to keep the instructions updated easily.

### Method 1: Copying Files Directly (One-off)

Copy the orchestrator and domain instruction files directly to your project's root and `.github/` folder:

```bash
cp copilot-instructions.md /your/project/.github/
cp ANTIGRAVITY.md /your/project/
cp GEMINI.md /your/project/
cp -r instructions /your/project/.github/
```

### Method 2: Integrating as a Git Submodule (Recommended)

To easily pull updates and share rules across multiple repositories, add this repository as a Git submodule:

```bash
# From the root of your project:
git submodule add git@github.com:Adrixan/copilot-instructions.git .github/copilot-instructions
```

To ensure all agents (GitHub Copilot, Gemini-cli, and Antigravity) automatically discover and load the rules, establish symbolic links mapping the submodule contents to the expected paths.

#### Unix / macOS (Linux, macOS, WSL)

Run these commands from your project root:

```bash
# 1. Create the .github directory (if it doesn't exist)
mkdir -p .github

# 2. Symlink orchestrator and domain instructions for GitHub Copilot
# (We run these relative to the .github/ directory so the links resolve correctly)
ln -sf copilot-instructions/copilot-instructions.md .github/copilot-instructions.md
ln -sf copilot-instructions/instructions .github/instructions

# 3. Symlink orchestrator files and instructions for Antigravity & Gemini-cli at the root
ln -sf .github/copilot-instructions/ANTIGRAVITY.md ANTIGRAVITY.md
ln -sf .github/copilot-instructions/GEMINI.md GEMINI.md
ln -sf .github/copilot-instructions/instructions instructions
```

#### Windows (PowerShell)

Ensure **Developer Mode** is enabled on your Windows machine, then run the following commands in PowerShell from the project root:

```powershell
# 1. Create symlinks for GitHub Copilot inside .github
New-Item -ItemType SymbolicLink -Path ".github\copilot-instructions.md" -Value "copilot-instructions\copilot-instructions.md"
New-Item -ItemType SymbolicLink -Path ".github\instructions" -Value "copilot-instructions\instructions"

# 2. Create root-level symlinks for Antigravity & Gemini-cli
New-Item -ItemType SymbolicLink -Path "ANTIGRAVITY.md" -Value ".github\copilot-instructions\ANTIGRAVITY.md"
New-Item -ItemType SymbolicLink -Path "GEMINI.md" -Value ".github\copilot-instructions\GEMINI.md"
New-Item -ItemType SymbolicLink -Path "instructions" -Value ".github\copilot-instructions\instructions"
```

To ensure Git handles symlinks correctly across your team's Windows environments when checking out the project, configure Git:

```bash
git config core.symlinks true
```

#### Alternative for Gemini-cli (Wrapper File)

If you prefer not to use symlinks for Gemini-cli, you can create a `GEMINI.md` file at your project's root and use the `@include` directive to import the instructions from the submodule:

```markdown
@include .github/copilot-instructions/GEMINI.md
```

#### Updating Submodule Instructions

To pull the latest updates from this repository into your project, run:

```bash
git submodule update --remote --merge
```

### How It Works

Different agents automatically load their respective orchestrator files:
- **GitHub Copilot** loads `.github/copilot-instructions.md`.
- **Antigravity** loads `ANTIGRAVITY.md`.
- **Gemini** loads `GEMINI.md`.

The orchestrator detects file types via `applyTo` frontmatter patterns (e.g. `applyTo: "*.py"`) and loads domain-specific guidelines from the `instructions/` folder.

### Customize for Your Project

Edit the orchestrator files to add project-specific conventions, internal library references, team standards, and architectural decisions.


## Key Features

- **Behavioral Discipline:** Debug protocol (two-attempt rule), approval gates (no silent pivoting),
  honest opposition (pushback on bad ideas), existing code protocol (read before touch),
  speed vs. correctness guardrails, context recovery on long sessions
- **Security by Default:** OWASP Top 10, CIS benchmarks, SLSA supply chain,
  SAST/DAST in CI, no hardcoded secrets, input validation, CSP
- **TDD Workflow:** Test-first for business logic, linting/validation for infrastructure
- **Type Safety:** TypeScript 5.6+ strict mode, Python 3.12+ type hints,
  Java 21 records, PHP 8.3+ strict types, Go generics, Rust ownership, .NET strict typing
- **Accessibility:** WCAG 2.1 AA, semantic HTML, ARIA, keyboard navigation
- **Observability:** OpenTelemetry for traces/metrics/logs, structured JSON logging, Prometheus/Grafana
- **i18n:** Mandatory translation keys, locale-aware formatting
- **AI Safety:** Prompt injection prevention, output sanitization, cost controls
- **Theme-First Design:** Design tokens before components, no inline styles, intentional visual direction
- **Priority System:** Security > Correctness > Accessibility > Performance > Maintainability > Style
- **Decision Logging:** Structured DECISIONS.md with chosen/alternatives/why/trade-offs/revisit-if format
- **Periodic Analysis:** Offered at sprint boundaries — performance, security, coverage, a11y, SOLID
- **Common Pitfalls:** Anti-patterns with corrections (❌/✅ format) in every instruction file

## What Changed in the Opus 4.6 Overhaul

### Orchestrator

- Removed nested backtick fences — clean YAML frontmatter + XML structure
- Added `<priority_order>` for conflict resolution (security > correctness > ...)
- Added `<reasoning_protocol>` for complex architectural decisions
- Added `<output_templates>` for structured requirements and decision logs
- Added SAST scan requirement in `<quality_gates>`
- Added OpenTelemetry in `<workflow_mandates>` observability

### Technology Updates

- Python 3.11+ → **3.12+** (type statement, @override, Ruff replaces Black+isort)
- Java 17 → **21 LTS** (virtual threads, pattern matching, sequenced collections)
- PHP 8.2+ → **8.3+** (typed class constants, #[\Override], json_validate)
- Spring Boot 3.x → **3.3+** (virtual threads, GraalVM native image)
- React → **React 19** (Compiler, Actions, use() hook)
- Next.js → **Next.js 15** (Turbopack, Partial Prerendering)
- TypeScript → **5.6+** (isolatedDeclarations, noUncheckedSideEffectImports)
- Terraform >= 1.5 → **1.7+** (import blocks, removed blocks, terraform test)
- FID <100ms → **INP <200ms** (Core Web Vitals updated March 2024)

### New Domains

- **Go** (`backend-go.instructions.md`) — Go 1.22+, error handling, concurrency, sqlc
- **.NET / C#** (`backend-dotnet.instructions.md`) — ASP.NET Core, constructor DI, layered architecture, async/CancellationToken
- **Rust** (`backend-rust.instructions.md`) — Ownership patterns, thiserror/anyhow, Tokio, unsafe discipline
- **Swift / SwiftUI** (`mobile-swift.instructions.md`) — MVVM, async/await, memory management, @MainActor
- **Kotlin / Android** (`mobile-kotlin.instructions.md`) — Coroutine scopes, sealed UI state, Compose theming
- **Flutter / Dart** (`mobile-flutter.instructions.md`) — Widget granularity, Riverpod/Bloc, AppTheme, platform isolation
- **AI/ML Integration** (`ai-integration.instructions.md`) — prompt injection, output safety, cost controls
- **OpenTofu** — added as Terraform alternative
- **Podman/Containerfile** — added to Docker instruction patterns

- **Debug Protocol** — Two-attempt rule, structured analysis before attempt 3, reproduce-before-fix
- **Existing Code Protocol** — Read before touch, understand patterns, separate refactoring from features
- **Approval Gates** — No silent pivoting, scope reduction, or approach changes without user approval
- **Honest Opposition** — State disagreements directly, validate with reasoning not agreement
- **Speed vs. Correctness** — "Working" ≠ "production-ready", no silent scope cuts
- **Context Recovery** — Re-read state file every turn, never rely on conversation history alone
- **Decision Logging** — DECISIONS.md with structured entries (chosen/alternatives/why/trade-offs)
- **Periodic Analysis** — Offered at sprint boundaries for targeted code quality review
- **Theme-First Design** — Design tokens before components, no inline styles, intentional visual direction

### Security Enhancements

- SLSA framework for supply chain integrity across all ops instructions
- SAST/DAST pipeline guidance (Semgrep, CodeQL, OWASP ZAP, Trivy, gosec)
- AI output sanitization rules in web and AI integration instructions

### Quality Improvements

- Consistent ❌/✅ pitfall format across all domain files
- API versioning guidance in backend-shared
- OpenTelemetry observability guidance in backend-shared and ops-shared
- Cross-references between shared and domain-specific instruction files
- `kubeconform` replaces deprecated `kubeval`

## Repository Structure

```text
copilot-instructions/
├── copilot-instructions.md        # GitHub Copilot Orchestrator (includes behavioral discipline rules)
├── ANTIGRAVITY.md                 # Antigravity Orchestrator
├── GEMINI.md                      # Gemini Orchestrator
├── instructions/
│   ├── backend-shared.instructions.md    # Backend: shared security, testing, architecture
│   ├── backend-python.instructions.md    # Python 3.12+ standards
│   ├── backend-java.instructions.md      # Java 21 / Spring Boot 3.3+ standards
│   ├── backend-go.instructions.md        # Go 1.22+ standards
│   ├── backend-php.instructions.md       # PHP 8.3+ standards
│   ├── backend-dotnet.instructions.md    # .NET / C# / ASP.NET Core standards (NEW)
│   ├── backend-rust.instructions.md      # Rust standards (NEW)
│   ├── backend-sql.instructions.md       # SQL standards
│   ├── ai-integration.instructions.md    # AI/ML integration security
│   ├── ops-shared.instructions.md        # DevOps: shared security, architecture
│   ├── ops-docker.instructions.md        # Docker / Podman standards
│   ├── ops-kubernetes.instructions.md    # Kubernetes standards
│   ├── ops-terraform.instructions.md     # Terraform / OpenTofu standards
│   ├── ops-ansible.instructions.md       # Ansible standards
│   ├── scripting-shared.instructions.md  # Scripting: shared security, validation
│   ├── scripting-bash.instructions.md    # Bash standards
│   ├── scripting-powershell.instructions.md # PowerShell standards
│   ├── web.instructions.md               # React 19 / Next.js 15 / TS 5.6+ (+ theme-first workflow)
│   ├── mobile-swift.instructions.md      # Swift / SwiftUI standards (NEW)
│   ├── mobile-kotlin.instructions.md     # Kotlin / Android / Compose standards (NEW)
│   └── mobile-flutter.instructions.md    # Flutter / Dart standards (NEW)
├── README.md
└── LICENSE
```

## Contributing

1. Fork → feature branch → update instruction file → PR
2. Follow existing patterns: security-first, strict behavior control, documented, ❌/✅ pitfall format

## License

GNU Affero General Public License v3 — see [LICENSE](LICENSE).

## Resources

- [GitHub Copilot Documentation](https://docs.github.com/en/copilot)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [OWASP API Security Top 10](https://owasp.org/www-project-api-security/)
- [SLSA Framework](https://slsa.dev/)
- [OpenTelemetry Documentation](https://opentelemetry.io/docs/)
- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [CIS Benchmarks](https://www.cisecurity.org/cis-benchmarks)
