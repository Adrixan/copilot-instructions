# Product Backlog & Plan

## User Stories

### Story 1: Add git submodule setup instructions for coding agents
- **Story:** As a developer, I want to add this repository as a git submodule to my project, so that my coding agents (GitHub Copilot, Gemini-cli, and Antigravity) automatically discover and follow the development instructions.
- **Priority:** Must (MoSCoW)
- **Story Points:** 2
- **Status:** Done
- **Acceptance Criteria:**
  1. Update `README.md` to include a new, detailed section on "Using as a Git Submodule".
  2. Provide step-by-step git commands to add the repository as a submodule.
  3. Include clear symlinking commands for Linux/macOS (`ln -s`) to map the orchestrator files (`copilot-instructions.md`, `ANTIGRAVITY.md`, `GEMINI.md`) and the `instructions/` directory to their correct locations (`.github/copilot-instructions.md`, `.github/instructions/`, `ANTIGRAVITY.md`, `GEMINI.md`, `instructions/`).
  4. Include PowerShell commands for Windows (`New-Item -ItemType SymbolicLink`) to achieve the same mapping, noting git symlink support configuration (`git config core.symlinks true`).
  5. Explain the alternative for `gemini-cli` using the `@include` syntax in a root `GEMINI.md` file.
  6. Ensure all Markdown headings follow a proper hierarchy and links are descriptive (Accessibility baseline - mandatory).
  7. No security credentials or sensitive info included (Security baseline - mandatory).

### Story 2: Multi-agent overhaul — lean core, real examples, verified pickup
- **Story:** As a developer, I want one lean instruction core with opt-in Agile ceremony, working example files, and automatic pickup by Claude Code, OpenCode, Copilot, Gemini, and Antigravity, so that the instructions actually reach every agent in every project without bloat or dead references.
- **Priority:** Must (MoSCoW)
- **Story Points:** 8
- **Status:** In Progress (implementation complete, pending user review)
- **Acceptance Criteria:**
  1. Canonical `AGENTS.md` orchestrator with synced entry points `CLAUDE.md`, `GEMINI.md`, `ANTIGRAVITY.md`, `copilot-instructions.md` (Copilot copy carries `applyTo` frontmatter).
  2. Agile lifecycle extracted to `instructions/agile-lifecycle.md`, loaded on demand (managed mode only).
  3. Every `examples/` reference resolves to a real file; Python example tests pass.
  4. Version pins reconciled with the latest-stable mandate; deprecated kubeval reference fixed.
  5. backend-shared baseline applies to `*.rs`/`*.cs`; ai-integration to `*.go`/`*.cs`.
  6. CI validates: markdownlint, relative links, entry-point sync, frontmatter.
  7. README documents entry points, integration (copy + submodule), and managed mode.
  8. No security credentials or sensitive info included (Security baseline - mandatory).
