# AI Coding Agent Instructions Collection

A comprehensive set of best-practice instructions to efficiently and securely develop across
various architectures using **Claude Code, GitHub Copilot, OpenCode, Gemini CLI, Antigravity**,
and any other [AGENTS.md](https://agents.md/)-compatible agent.

## Overview

Domain-specific instruction files that govern the behavior of automated coding agents to
generate secure, maintainable, and high-quality code. They enforce security baselines
(OWASP, CIS, SLSA), testing discipline, and explicit constraints against common AI failure
modes: silent scope reduction, context loss, brute-force debugging, error masking, and code
recklessness.

The architecture separates **always-on discipline** from **opt-in ceremony**:

- The **orchestrator** (`AGENTS.md` and its synced copies) is deliberately lean: priority
  order, behavioral rules, debug protocol, existing-code protocol, decision logging, and the
  mandatory security/accessibility baselines. This is what lives in every agent's context.
- The **Agile/TDD lifecycle** (user profiling, sprints, user stories, per-story acceptance)
  lives in [`instructions/agile-lifecycle.md`](instructions/agile-lifecycle.md) and applies
  only in **managed mode**: greenfield builds, or projects that maintain `.agents/` state
  files. Routine work in existing codebases never pays that ceremony cost.
- **Domain files** in [`instructions/`](instructions/) are loaded by file type (Copilot
  `applyTo` globs; other agents read the matching file before editing).

## Agent Entry Points

All entry points are generated from the single canonical source `AGENTS.md`
(run `scripts/sync-entrypoints.sh`; CI verifies they never drift).

| Agent | Loads automatically |
| ----- | ----------------- |
| Claude Code | `CLAUDE.md` (project root) |
| OpenCode (and Cursor, Codex CLI, Jules, Amp, Copilot coding agent…) | `AGENTS.md` (project root) |
| GitHub Copilot | `.github/copilot-instructions.md` + `.github/instructions/*.instructions.md` |
| Gemini CLI | `GEMINI.md` (project root) |
| Antigravity | `AGENTS.md` / `GEMINI.md` (workspace root — [Antigravity best practices](https://antigravity.google/docs/cli/best-practices/)); `ANTIGRAVITY.md` kept as fallback |

GitHub Copilot additionally auto-loads the domain files via their `applyTo` frontmatter.
All other agents are instructed by the orchestrator to read the matching domain file(s)
before writing code.

## Instruction Files

Located in [`instructions/`](instructions/). Files are split by language/tool so only
relevant instructions are loaded per file type, minimizing context usage:

| File | Domain | applyTo |
| ------ | -------- | --------- |
| [backend-shared](instructions/backend-shared.instructions.md) | Backend (all) | `*.py`, `*.java`, `*.go`, `*.php`, `*.rs`, `*.cs`, `*.sql` |
| [backend-python](instructions/backend-python.instructions.md) | Python 3.12+ | `*.py` |
| [backend-java](instructions/backend-java.instructions.md) | Java 21+ LTS / Spring Boot | `*.java` |
| [backend-go](instructions/backend-go.instructions.md) | Go 1.22+ | `*.go`, `go.mod`, `go.sum` |
| [backend-php](instructions/backend-php.instructions.md) | PHP 8.3+ / Laravel / Symfony | `*.php` |
| [backend-dotnet](instructions/backend-dotnet.instructions.md) | .NET LTS / C# (ASP.NET Core) | `*.cs`, `*.csproj`, `*.sln`, `*.razor` |
| [backend-rust](instructions/backend-rust.instructions.md) | Rust | `*.rs`, `Cargo.toml`, `Cargo.lock` |
| [backend-sql](instructions/backend-sql.instructions.md) | SQL | `*.sql` |
| [ai-integration](instructions/ai-integration.instructions.md) | AI/ML Integration | `*.py`, `*.ts`, `*.js`, `*.java`, `*.go`, `*.cs` |
| [ops-shared](instructions/ops-shared.instructions.md) | DevOps (all) | Dockerfiles, infra YAML, `*.tf`, `*.hcl` |
| [ops-docker](instructions/ops-docker.instructions.md) | Docker / Podman | `Dockerfile*`, `Containerfile*`, `docker-compose*` |
| [ops-kubernetes](instructions/ops-kubernetes.instructions.md) | Kubernetes | `k8s/**`, `kubernetes/**`, `helm/**` |
| [ops-terraform](instructions/ops-terraform.instructions.md) | Terraform / OpenTofu | `*.tf`, `*.tfvars`, `*.hcl` |
| [ops-ansible](instructions/ops-ansible.instructions.md) | Ansible | `ansible/**`, `playbooks/**` |
| [scripting-shared](instructions/scripting-shared.instructions.md) | Scripting (all) | `*.sh`, `*.ps1` |
| [scripting-bash](instructions/scripting-bash.instructions.md) | Bash | `*.sh` |
| [scripting-powershell](instructions/scripting-powershell.instructions.md) | PowerShell | `*.ps1` |
| [web](instructions/web.instructions.md) | Frontend (React / Next.js / TS) | `*.html`, `*.css`, `*.js`, `*.ts`, `*.jsx`, `*.tsx` |
| [mobile-swift](instructions/mobile-swift.instructions.md) | Swift / SwiftUI (iOS/macOS) | `*.swift`, `Package.swift`, `*.xcodeproj` |
| [mobile-kotlin](instructions/mobile-kotlin.instructions.md) | Kotlin / Android / Compose | `*.kt`, `*.kts`, `build.gradle*` |
| [mobile-flutter](instructions/mobile-flutter.instructions.md) | Flutter / Dart | `*.dart`, `pubspec.yaml` |

Not a loaded instruction file, but referenced by the orchestrator:

- [`instructions/agile-lifecycle.md`](instructions/agile-lifecycle.md) — managed-mode Agile/TDD lifecycle (read on demand).
- [`examples/`](examples/README.md) — working code demonstrations referenced by the domain files.

## Quick Start

Copy the files directly into your project, or integrate this repository as a Git submodule
to keep the instructions updated easily.

### Method 1: Copying Files Directly (One-off)

From your project root:

```bash
cp /path/to/copilot-instructions/{AGENTS.md,CLAUDE.md,GEMINI.md,ANTIGRAVITY.md,copilot-instructions.md} .
mkdir -p .github
cp copilot-instructions.md .github/copilot-instructions.md
cp -r /path/to/copilot-instructions/instructions .github/instructions
cp -r /path/to/copilot-instructions/instructions .   # root copy for non-Copilot agents
cp -r /path/to/copilot-instructions/examples .
```

### Method 2: Integrating as a Git Submodule (Recommended)

```bash
# From the root of your project:
git submodule add git@github.com:Adrixan/copilot-instructions.git .github/copilot-instructions
```

Then establish symbolic links mapping the submodule contents to the paths each agent expects.

#### Unix / macOS (Linux, macOS, WSL)

Run from your project root:

```bash
mkdir -p .github

# GitHub Copilot
ln -sf copilot-instructions/copilot-instructions.md .github/copilot-instructions.md
ln -sf copilot-instructions/instructions .github/instructions

# Root-level entry points: Claude Code, OpenCode/AGENTS.md tools, Gemini, Antigravity
ln -sf .github/copilot-instructions/CLAUDE.md CLAUDE.md
ln -sf .github/copilot-instructions/AGENTS.md AGENTS.md
ln -sf .github/copilot-instructions/GEMINI.md GEMINI.md
ln -sf .github/copilot-instructions/ANTIGRAVITY.md ANTIGRAVITY.md
ln -sf .github/copilot-instructions/instructions instructions
ln -sf .github/copilot-instructions/examples examples
```

#### Windows (PowerShell)

Enable **Developer Mode**, then run from your project root:

```powershell
New-Item -ItemType SymbolicLink -Path ".github\copilot-instructions.md" -Value "copilot-instructions\copilot-instructions.md"
New-Item -ItemType SymbolicLink -Path ".github\instructions" -Value "copilot-instructions\instructions"

New-Item -ItemType SymbolicLink -Path "CLAUDE.md" -Value ".github\copilot-instructions\CLAUDE.md"
New-Item -ItemType SymbolicLink -Path "AGENTS.md" -Value ".github\copilot-instructions\AGENTS.md"
New-Item -ItemType SymbolicLink -Path "GEMINI.md" -Value ".github\copilot-instructions\GEMINI.md"
New-Item -ItemType SymbolicLink -Path "ANTIGRAVITY.md" -Value ".github\copilot-instructions\ANTIGRAVITY.md"
New-Item -ItemType SymbolicLink -Path "instructions" -Value ".github\copilot-instructions\instructions"
New-Item -ItemType SymbolicLink -Path "examples" -Value ".github\copilot-instructions\examples"
```

To ensure Git handles symlinks correctly across Windows environments:

```bash
git config core.symlinks true
```

#### Alternative for Gemini-cli (Wrapper File)

If you prefer not to use symlinks for Gemini-cli, create a `GEMINI.md` at your project's
root with the `@include` directive:

```markdown
@include .github/copilot-instructions/GEMINI.md
```

#### Updating Submodule Instructions

```bash
git submodule update --remote --merge
```

### How It Works

Every agent loads its own entry point; all entry points are byte-identical copies of the
canonical `AGENTS.md` (except the Copilot copy, which carries the `applyTo: "**"`
frontmatter). The orchestrator tells each agent how to find domain rules and when to load
the managed-mode lifecycle.

### Managed Mode

For greenfield projects (or projects keeping `.agents/` state files), the orchestrator
directs the agent to [`instructions/agile-lifecycle.md`](instructions/agile-lifecycle.md):
user profiling, requirements/user-story protocol, sprint planning, per-story TDD with user
acceptance, and structured state files (`.agents/templates/` provides starting templates).
Existing codebases get the discipline rules without the ceremony.

### Customize for Your Project

Edit the orchestrator (`AGENTS.md`, then run `scripts/sync-entrypoints.sh`) to add
project-specific conventions, internal library references, team standards, and
architectural decisions.

## Key Features

- **Behavioral Discipline:** debug protocol (two-attempt rule), approval gates (no silent
  pivoting), honest opposition (pushback on bad ideas), existing-code protocol (read before
  touch), speed-vs-correctness guardrails, session-based context recovery
- **Security by Default:** OWASP Top 10, OWASP API Security, CIS benchmarks, SLSA supply
  chain, SAST/DAST in CI, no hardcoded secrets, input validation, CSP
- **Testing Discipline:** test-first for business logic, linting/validation for
  infrastructure, Testcontainers for integration, lint/validate for IaC
- **Type Safety:** TypeScript strict mode, Python type hints, Java records, PHP strict
  types, Go interfaces, Rust ownership, .NET nullable reference types
- **Accessibility:** WCAG 2.1 AA mandatory NFRs, semantic HTML, ARIA, keyboard navigation
- **Observability:** OpenTelemetry, structured JSON logging, Prometheus/Grafana
- **i18n:** mandatory translation keys, locale-aware formatting
- **AI Safety:** prompt injection prevention, output sanitization, cost controls
- **Theme-First Design:** design tokens before components, no inline styles
- **Priority System:** Security > Correctness > Accessibility > Performance > Maintainability > Style
- **Decision Logging:** DECISIONS.md with chosen/alternatives/why/trade-offs/revisit-if
- **Common Pitfalls:** anti-patterns with corrections (❌/✅ format) in every instruction file
- **Examples:** working code demonstrations in [`examples/`](examples/README.md)

## What Changed in the 2026-09 Overhaul

### Multi-Agent Entry Points

- New canonical `AGENTS.md` orchestrator; synced copies `CLAUDE.md` (Claude Code),
  `GEMINI.md` (Gemini CLI), `ANTIGRAVITY.md`, and `copilot-instructions.md` (GitHub Copilot)
- `scripts/sync-entrypoints.sh` regenerates copies; `scripts/check-sync.sh` guards drift in CI
- OpenCode, Cursor, Codex CLI and other AGENTS.md-compatible tools now covered natively

### Lean Core / Opt-In Ceremony

- Orchestrator slimmed ~40%: lifecycle protocols (profiling, requirements, sprints,
  development loop, templates) extracted to `instructions/agile-lifecycle.md`,
  read on demand in **managed mode** only
- Task triage replaces the mandatory 10-step lifecycle for every task
- State files read at session start / on ambiguity — not re-read every turn
- Hard size limits (≤50-line functions etc.) became heuristics; the 10,000-LOC
  microservices threshold replaced by bounded-context guidance

### Integrity

- `examples/` tree created — every referenced example now exists (React, Python, Java,
  PHP, integration tests, JWT auth, Alembic, Docker, Kubernetes, Terraform, Ansible,
  CI pipeline, Bash/BATS, PowerShell/Pester, ops pitfalls)
- CI validation restored: markdownlint, relative link check, entry-point sync check,
  frontmatter check (`.github/workflows/validate.yml`)
- Deprecated `kubeval` reference replaced with `kubeconform`
- Version pins reconciled with the latest-stable mandate (minimums + "current stable")
- backend-shared baseline now also applies to `*.rs` and `*.cs`; ai-integration to
  `*.go`/`*.cs`; web instructions scoped to frontend/UI code
- Account-lockout guidance updated to rate limiting + progressive delays (OWASP/NIST)
- `.agents/templates/` added so downstream projects start from neutral state files

## Repository Structure

```text
copilot-instructions/
├── AGENTS.md                        # Canonical orchestrator (OpenCode, Antigravity, …)
├── CLAUDE.md                        # Claude Code entry (synced copy)
├── GEMINI.md                        # Gemini CLI entry (synced copy)
├── ANTIGRAVITY.md                   # Antigravity fallback (synced copy)
├── copilot-instructions.md          # Copilot entry (synced copy + applyTo frontmatter)
├── instructions/
│   ├── agile-lifecycle.md           # Managed-mode Agile/TDD lifecycle (read on demand)
│   ├── backend-shared.instructions.md
│   ├── backend-python.instructions.md
│   ├── backend-java.instructions.md
│   ├── backend-go.instructions.md
│   ├── backend-php.instructions.md
│   ├── backend-dotnet.instructions.md
│   ├── backend-rust.instructions.md
│   ├── backend-sql.instructions.md
│   ├── ai-integration.instructions.md
│   ├── ops-shared.instructions.md
│   ├── ops-docker.instructions.md
│   ├── ops-kubernetes.instructions.md
│   ├── ops-terraform.instructions.md
│   ├── ops-ansible.instructions.md
│   ├── scripting-shared.instructions.md
│   ├── scripting-bash.instructions.md
│   ├── scripting-powershell.instructions.md
│   ├── web.instructions.md
│   ├── mobile-swift.instructions.md
│   ├── mobile-kotlin.instructions.md
│   └── mobile-flutter.instructions.md
├── examples/                        # Working code demonstrations (see examples/README.md)
├── .agents/
│   ├── templates/                   # Neutral state-file templates for new projects
│   ├── project-state.md             # This repo's own managed-mode state
│   ├── plan.md
│   └── to-do.md
├── scripts/
│   ├── sync-entrypoints.sh          # Regenerate entry points from AGENTS.md
│   ├── check-sync.sh                # CI: entry points in sync
│   ├── check-links.sh               # CI: relative markdown links resolve
│   └── check-frontmatter.sh         # CI: applyTo frontmatter present
├── .github/workflows/validate.yml   # CI: lint + links + sync + frontmatter
├── README.md
└── LICENSE
```

## Contributing

1. Fork → feature branch → update instruction file → PR
2. Follow existing patterns: security-first, strict behavior control, documented, ❌/✅ pitfall format
3. Edit the canonical `AGENTS.md`, then run `scripts/sync-entrypoints.sh`
4. CI must pass: markdownlint, link check, sync check, frontmatter check

## License

GNU Affero General Public License v3 — see [LICENSE](LICENSE).

## Resources

- [GitHub Copilot Documentation](https://docs.github.com/en/copilot)
- [AGENTS.md Standard](https://agents.md/)
- [Claude Code Memory / CLAUDE.md](https://docs.anthropic.com/en/docs/claude-code)
- [OpenCode Rules](https://opencode.ai/docs/rules/)
- [Antigravity Best Practices](https://antigravity.google/docs/cli/best-practices/)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [OWASP API Security Top 10](https://owasp.org/www-project-api-security/)
- [SLSA Framework](https://slsa.dev/)
- [OpenTelemetry Documentation](https://opentelemetry.io/docs/)
- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [CIS Benchmarks](https://www.cisecurity.org/cis-benchmarks)
