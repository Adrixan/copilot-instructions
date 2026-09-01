# Managed Mode: Agile / TDD Lifecycle

**Read this file only in managed mode** — when the user starts a greenfield project with these
instructions, or the project already maintains `.agents/` state files. For routine work in
existing codebases, the orchestrator (`AGENTS.md` / `copilot-instructions.md` / `CLAUDE.md`)
alone applies; do not impose this lifecycle there.

This file is named `agile-lifecycle.md` (not `*.instructions.md`) on purpose: it is read
on demand, never auto-loaded for every file.

<Task Lifecycle>
1. Read `.agents/project-state.md`, `.agents/plan.md`, and `.agents/to-do.md` for context. If missing, run `protocol_initialization`.
2. Profile the user (`user_profiling`) — ask once per project if no profile recorded.
3. Classify: new project → `protocol_initialization`; non-trivial change → `protocol_requirements`; trivial fix → proceed directly.
4. Requirements and design: Gather → Refine → Write User Stories → Build Product Backlog → Confirm. No code until confirmed.
5. Scaffold: project structure, configuration, dependencies, i18n framework — no feature logic yet.
6. Sprint Planning: select stories → set sprint goal → user confirms scope (`protocol_sprint_planning`).
7. Implement via `protocol_development_loop` (one user story at a time, TDD, user acceptance after each).
8. Sprint Review & Retrospective after all sprint stories are processed.
9. Backlog refinement → next sprint (return to step 6).
10. Update the state files after every story completion and sprint boundary.

Steps 2–4 are not optional for non-trivial work in managed mode.
</Task Lifecycle>

<state_files>
Files: `.agents/project-state.md`, `.agents/plan.md`, `.agents/to-do.md`.

Captures: OS, package manager, shell, stack, user profile, accessibility, localization,
architecture, testing strategy, requirements log, decisions log, sprint history, skipped-tests log.

**Product Backlog & Plan** (`.agents/plan.md`)

- Ordered list of user stories with priority (MoSCoW: Must / Should / Could / Won't)
- Each story: `As a [role], I want [capability], so that [benefit]`
- Each story has numbered acceptance criteria, story point estimate, and status

**Sprint Backlog & To-Do** (`.agents/to-do.md`)

- Sprint goal (one sentence)
- Selected stories for this sprint, pulled from the top of the product backlog
- Current story sub-task status:

  ```text
  - [ ] Acceptance tests written
  - [ ] Implementation complete (all tests green)
  - [ ] Regression suite green
  - [ ] User review: approved / feedback / pending
  ```

**Sprint History & Open Items** (`.agents/project-state.md`)

- Completed sprints: goal, stories delivered, stories carried over, velocity
- Pending user feedback, open questions, impediments, technical debt
</state_files>

<user_profiling>
Trigger: no `## User Profile` section in the state file. Ask once:
"How would you describe your development experience?"

1. **Citizen** — Not a programmer; handle all technical decisions for me.
2. **Intermediate** — Some knowledge; give me up to 3 choices per decision.
3. **Senior** — Full control; show all options with detailed trade-offs.

Record in state file. Profile governs depth of all interactions:

| Aspect | Citizen | Intermediate | Senior |
|--------|---------|-------------|--------|
| Init questions | What, who, deployment type only | + simplified tech prefs (max 3) | Full interview |
| Tech stack | Auto-selected, user informed | Up to 3 options, recommendation highlighted | 2–5 options with pros/cons |
| Architecture | Auto-selected | Simplified choice with brief explanation | Full trade-off analysis |
| **UI decisions** | **Always ask** | **Always ask** | **Always ask** |
| Requirements | Plain language, no jargon | Light technical language | Full structured requirements |
| Decisions | Auto with rationale | Max 3 options, recommend | Full protocol, user decides |
| Feature suggestions | User-facing terms | Light technical context | Full technical detail |

Profile affects style, not quality — all profiles get the same security/testing/quality standards.
Transition on request.

**UI decisions are never auto-decided.** Any choice affecting visual appearance, layout, theming,
color scheme, typography, component style, or interaction patterns must be presented to the user
regardless of profile — including component libraries, CSS approaches, and design system choices.
</user_profiling>

<protocol_initialization>
Trigger: no state files, new/empty project, or new project idea. Run `user_profiling` first if needed.

- **Citizen:** auto-detect env → ask what to build + who for + deployment type + localization + licensing → auto-decide stack/architecture → inform user → proceed to requirements.
- **Intermediate:** auto-detect env → demographics → app type → architecture (max 3 options) → stack (max 3, highlighted recommendation) → localization → licensing (max 3) → confirm TDD → proceed to requirements.
- **Senior:** auto-detect env → demographics → app type + architecture (detailed trade-offs) → stack (2–5 options, pros/cons) → i18n → licensing → testing strategy discussion → proceed to requirements.

Stack selection rules (all profiles):

- **Prefer latest stable versions** of frameworks, libraries, and runtimes; avoid deprecated/EOL versions.
- **Static websites → static site generator** (Hugo, Astro, Eleventy, Jekyll) when feasible. Fall back to dynamic frameworks only when server-side logic, real-time data, or authenticated dynamic content is genuinely required.

UI prompt (all profiles, projects with a UI):

- **Dark mode:** ask *"Would you like to include dark mode support?"* Options: light only, dark only, both with system-preference detection (recommended), user-togglable. Record the choice.

Always proceed to `protocol_requirements` after initialization. Never jump to coding.
</protocol_initialization>

<protocol_requirements>
Applies to every non-trivial task in managed mode (new features, changes, refactors, ambiguous
bugs, cross-cutting concerns). Skip for typo fixes, single-line config tweaks, formatting.

Workflow (adapt depth to profile):

1. **Gather**: explicit requirements, assumptions, open questions, constraints.
2. **Ask**: open questions, options (citizen: auto-decide technical; intermediate: max 3; senior: 2–4 with pros/cons), assumptions to confirm.
3. **Refine**: loop on new ambiguities until none remain.
4. **Write User Stories**:
   - Format: `As a [role], I want [capability], so that [benefit]`
   - Numbered **acceptance criteria** — testable, specific, measurable
   - Estimate in story points (1 / 2 / 3 / 5 / 8 / 13); split stories above 8 points
   - Prioritize with MoSCoW; stories must be **INVEST** (Independent, Negotiable, Valuable, Estimable, Small, Testable)
   - **Security acceptance criteria are mandatory.** For every story involving user input, authentication, data storage, network communication, file I/O, or third-party integrations, append applicable items from `mandatory_security_nfrs` as acceptance criteria. Non-negotiable, added by default.
   - **Accessibility acceptance criteria are mandatory.** For every story producing a user interface (web, mobile, desktop, CLI output, API errors, emails, PDFs), append applicable items from `mandatory_accessibility_nfrs`. Non-negotiable, added by default.
5. **Build Product Backlog**: ordered backlog, grouped by epic/theme where applicable; suggest 3–7 additional stories from domain knowledge; security/a11y ACs marked **(mandatory — auto-included)**. Loop until confirmed.
6. **Summarize**: functional requirements; mandatory NFRs (security + accessibility baselines — always included, never de-scoped); project-specific NFRs; out of scope; key decisions with rationale; full story list with ACs.
7. **Confirm**: explicit user approval required; any change returns to step 3. Mandatory NFRs can be tailored to context but never removed.

Record the confirmed backlog in `.agents/plan.md`. Reference during sprint planning.
</protocol_requirements>

<protocol_sprint_planning>
Trigger: scaffolding complete, product backlog confirmed.

1. **Set sprint goal.** One sentence tied to the highest-priority stories.
2. **Select stories** from the top of the backlog: 5–13 story points (adjust with velocity; default 8 for the first sprint).
3. **Break down tasks** per story (tests, implementation, i18n, docs). Internal planning — only Senior profiles see sub-task detail.
4. **Confirm with user.** Sprint goal + selected stories with acceptance criteria. User approves scope before work begins.
5. **Record** in state files under `## Current Sprint`.

Rules:

- Never add stories mid-sprint unless the user explicitly requests it (scope change — acknowledge trade-offs).
- If a story proves larger than estimated, split it; carry the remainder to the next sprint.
</protocol_sprint_planning>

<protocol_development_loop>
Goal: deliver each user story to "done" through TDD, automated validation, and explicit user
acceptance — one story at a time.

### Per-Story Workflow

1. **Acceptance Test Design**
   - Translate acceptance criteria **literally** into tests: each criterion → ≥1 test; cover happy path, edge cases, error handling.
   - **Security tests** for every mandatory security AC (injection attempts, auth bypass, invalid tokens, oversized payloads, path traversal). Not optional.
   - **Accessibility tests** for every mandatory accessibility AC (axe-core/pa11y scans, keyboard flows, label assertions, contrast, focus management). Not optional.
   - i18n/l10n string assertions where applicable.
   - Name tests to mirror the criterion: `test_<story_id>_<criterion_description>`.
   - Present the test plan (story title + test names, security tests flagged); user confirms or adjusts.
2. **Write Failing Tests (Red)** — all new tests must fail for the right reasons; investigate unexpected passes before proceeding.
3. **Implement (Green)** — minimum code to pass **all** acceptance tests; every user-facing string through i18n; verify against acceptance criteria.
4. **Refactor** — keep tests green throughout; no behavior changes; apply code quality heuristics.
5. **Regression Check** — run the **full** suite, not just new tests; fix regressions before proceeding. Never present a broken build.
6. **User Acceptance** — present a structured review:

   ```markdown
   ### Story Review: [Story Title]
   **Story:** As a [role], I want [capability], so that [benefit]

   **Acceptance Criteria & Test Results:**
   - [x] AC1: [description] — PASS (test_story01_criterion1)
   - [ ] AC3: [description] — FAIL (details)

   **Regression Suite:** X passed, Y failed
   **Demo:** [what was built, how to verify it]
   **Open Questions:** [items needing input]
   ```

   User responses: **Accept** → Done; **Request Changes** → apply, re-test, return here (normal
   inspect-and-adapt, not failure); **Reject** → back to backlog with notes; **Skip Review** →
   log as "accepted-unreviewed".
7. **Update State** — mark story Done/carried-over with date; record test counts, skipped tests, decisions, feedback; update burndown.

### Sprint Completion

1. **Review Summary** — goal achieved / partially / missed; delivered vs carried over; velocity; demo.
2. **Retrospective** — what went well, what to improve, action items. Record under `## Sprint History`.
3. **Backlog Refinement** — re-prioritize; present for confirmation.
4. **Periodic Analysis** — offer per `protocol_periodic_analysis` before the next sprint.
5. **Next Sprint** → `protocol_sprint_planning`.

### Rules

- **One story at a time.** Never implement multiple stories between reviews.
- **Never skip user acceptance** unless pre-approved batch mode or "Skip Review".
- **Regressions block progress.**
- **Localization gate:** all new strings exist in every configured locale before review.
- **State files always current** — primary mechanism for resuming in a new session.
- **Definition of Done** (all true before "Done"):
  1. All acceptance tests pass (including mandatory security and accessibility tests)
  2. Full regression suite passes
  3. Quality gates met (formatted, linted, no secrets, SAST clean)
  4. Applicable `mandatory_security_nfrs` verified
  5. Applicable `mandatory_accessibility_nfrs` verified
  6. i18n strings present in all configured locales
  7. Public APIs documented
  8. User explicitly accepted (or "Skip Review")
</protocol_development_loop>

<protocol_periodic_analysis>
At natural breakpoints (sprint end, major feature, pre-release), **offer** targeted analysis;
the user selects:

- Performance bottlenecks
- Security vulnerabilities
- Code duplication / modularity
- Maintainability & readability
- Project structure
- Dependency health
- Test coverage gaps
- Accessibility compliance
- SOLID violations
- Project-specific concerns (ask)

Do not run all checks silently. Run only what the user selects.
</protocol_periodic_analysis>

<output_templates>
User Story:

- **ID**: US-[number]
- **Story**: As a [role], I want [capability], so that [benefit]
- **Priority**: Must / Should / Could / Won't
- **Story Points**: [1/2/3/5/8/13]
- **Acceptance Criteria**: 1. Given [context], when [action], then [outcome] 2. …
- **Notes**: [constraints, dependencies, considerations]

Sprint Plan:

- **Sprint**: [number] — **Goal**: [one sentence] — **Stories**: [US-IDs + titles] — **Total Points**: [sum]

Story Review: as in step 6 of the per-story workflow.

Sprint Review Summary:

- **Sprint Goal**: achieved / partially / missed
- **Delivered**: [US-IDs] — **Carried Over**: [US-IDs] — **Velocity**: [points]
- **Retrospective**: went well / improve / action items

Requirements Summary:

- Functional: [numbered] — Non-Functional: [numbered] — Out of Scope: [numbered] — Key Decisions: [numbered with rationale]

Decision Log Entry: as in the orchestrator's `decision_protocol`.
</output_templates>
