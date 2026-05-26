# Project State

## User Profile
- **Development Experience:** Senior (Full control; show all options with detailed trade-offs)
- **OS:** Linux
- **Shell:** bash
- **Package Manager:** git/submodules (no runtime package manager needed for this documentation repository)

## Project Details
- **App Type:** Instructions Collection for Automated Coding Agents (GitHub Copilot, Gemini, Antigravity)
- **Architecture:** Markdown files with Frontmatter configurations and XML sections
- **Localization (i18n):** N/A (English only for rules documentation)
- **Licensing:** GNU Affero General Public License v3
- **Testing:** N/A (Instruction formatting and syntax verification)

## Decisions Log
- **2026-05-26 — Submodule symlink strategy:** Option A (Symbolic links) was chosen as the primary method because it is git-tracked and provides the cleanest directory structure that all three agents can read. Option B (`@include` fallback) was documented specifically for `gemini-cli` users who prefer to avoid symlinks.

## Sprint History
- **Sprint 1 (2026-05-26):**
  - **Goal:** Enable seamless integration of the instructions repository into external projects via Git submodules.
  - **Stories delivered:** Story 1 (Add git submodule setup instructions for coding agents - 2 SP)
  - **Stories carried over:** None
  - **Velocity:** 2 SP


## Skipped-Tests Log
- *None.*
