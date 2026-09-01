# Project State

## User Profile
- **Development Experience:** Senior (Full control; show all options with detailed trade-offs)
- **OS:** Linux
- **Shell:** bash
- **Package Manager:** git/submodules (no runtime package manager needed for this documentation repository)

## Project Details
- **App Type:** Instructions Collection for Automated Coding Agents (Claude Code, GitHub Copilot, OpenCode, Gemini CLI, Antigravity)
- **Architecture:** Markdown files with YAML frontmatter + XML sections; canonical AGENTS.md with synced per-agent entry points; on-demand Agile lifecycle; examples tree
- **Localization (i18n):** N/A (English only for rules documentation)
- **Licensing:** GNU Affero General Public License v3
- **Testing:** Instruction formatting/syntax verification (markdownlint), relative link check, entry-point sync check, frontmatter check, Python example unit tests

## Decisions Log
- **2026-05-26 — Submodule symlink strategy:** Option A (Symbolic links) was chosen as the primary method because it is git-tracked and provides the cleanest directory structure that all agents can read. Option B (`@include` fallback) was documented specifically for `gemini-cli` users who prefer to avoid symlinks.
- **2026-09-01 — Multi-agent entry strategy:** Canonical source is `AGENTS.md`; `CLAUDE.md`, `GEMINI.md`, `ANTIGRAVITY.md` are byte-identical synced copies; `copilot-instructions.md` adds the `applyTo: "**"` frontmatter. Rationale: every agent picks up its native convention while drift is prevented by `scripts/check-sync.sh` in CI. Revisit if: an agent requires materially different orchestrator content.
- **2026-09-01 — Ceremony extraction:** Agile lifecycle moved to `instructions/agile-lifecycle.md` (managed mode only) to keep the always-loaded orchestrator lean. Rationale: lifecycle applies to greenfield builds, not routine changes in existing codebases. Revisit if: agents prove unreliable at reading the lifecycle file on demand.
- **2026-09-01 — Antigravity conventions:** Antigravity officially reads `AGENTS.md`/`GEMINI.md` at the workspace root (per Antigravity docs); `ANTIGRAVITY.md` kept only as a fallback copy. User decision pending confirmation.

## Sprint History
- **Sprint 1 (2026-05-26):**
  - **Goal:** Enable seamless integration of the instructions repository into external projects via Git submodules.
  - **Stories delivered:** Story 1 (Add git submodule setup instructions for coding agents - 2 SP)
  - **Stories carried over:** None
  - **Velocity:** 2 SP
- **Sprint 2 (2026-09-01):**
  - **Goal:** Multi-agent overhaul — lean core, real examples, verified pickup by five agent ecosystems.
  - **Stories delivered:** pending user review (Story 2, 8 SP)
  - **Stories carried over:** None
  - **Velocity:** TBD

## Skipped-Tests Log
- *None.*
