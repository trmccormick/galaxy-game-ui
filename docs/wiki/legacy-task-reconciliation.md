# Legacy Task Reconciliation

**Status:** Planning reference — not a task queue  
**Last updated:** 2026-11-08

This page maps the earlier `agent-tasks/projects/galaxy-game-ui/` proposals to the current prototype direction. The source task files remain in `agent-tasks`; this page does not copy them or authorize dispatch.

## 1. First-attempt task plan

| Earlier proposal | Original purpose | Current treatment |
|---|---|---|
| Seeds cleanup / default users | Remove or change seed behavior in the early prototype | Do not carry forward without rechecking current authentication, seed data and the explicit decision to retain `UserCsvLoader`. The older plan contains a known conflict. |
| Public landing page | Rebuild public entry page using first-attempt layout and mock data | Landing page already exists in the active prototype history. Treat as existing work; only propose narrow changes after visual/code review. |
| Dashboard from `MockDataHelper` | Build dashboard panels against mock helper methods | Superseded as the target architecture. Preserve useful presentation patterns only; replace mock data with real API-backed data progressively. |
| T3a CSS foundation | Establish first-attempt styling foundation | Superseded by the current Tailwind CSS 4 / token-based prototype foundation. Do not recreate old Sass/EVE CSS setup. |
| T3a-2 layout shell | Replace WVU layout with first-attempt shell | The current prototype has a newer shell and branding work. Verify current behavior before proposing any shared-layout changes. |
| T3b JSON fixture loader | Load systems/links fixtures for the dashboard | Not the target data architecture. The new app needs a reader adapted from main-game lookup services and a Rails API boundary. |
| T3c dashboard overview | Show fixed Systems/Connections panels from fixtures | Exploratory wayfinding idea only. First workflow and content composition remain open. |
| Tasks 4–8: EVE CSS, topbar, six panels, admin view, responsive pass | Extend first-attempt mock dashboard | Do not execute as written. Re-evaluate each useful pattern against the current app and actual workflow. |

The older October plan's Devise, MockDataHelper, Sass and fixed-menu assumptions are not current implementation instructions.

## 2. Later draft proposals (2026-11-04)

The current project draft README identifies this proposed sequence:

| Draft | Original scope | Current planning disposition |
|---|---|---|
| Audit waypoint JS recovery | Read-only comparison of current prototype, first-attempt history and local backup | Keep as a candidate audit if not already completed. The local backup is read-only. The audit must distinguish original EVE source, first-attempt adaptation and current prototype code. |
| Finalize sign-in branding | Finish visual branding while preserving authentication | Reconcile with the latest committed sign-in work. Do not dispatch if the current sign-in page already meets the goal. |
| Replace landing logo | Use the approved existing Galaxy Game logo asset | Keep conditional on identifying the approved variant. Do not generate or select a new logo by guess. |
| Port waypoint navigation | Adapt a reusable waypoint interaction | Blocked on audit findings and Tracy's approval. It must not import EVE autopilot behavior or invent Galaxy Game route rules. |

These proposals were written against an earlier branch name and earlier prototype snapshot. Their paths, commits, state and acceptance criteria must be rechecked against the current `main` before use.

## 3. Other old backlog ideas

The older backlog also proposed:
- user profile/account page;
- a large admin dashboard skeleton;
- six fixed player dashboard panels;
- wormholes view and network visualization;
- mobile-specific layout pass.

These are not automatically current priorities. Evaluate each only after the first real player/admin workflows and source data are understood. In particular:
- player and admin interfaces have distinct responsibilities;
- an admin feature should correspond to actual administrative capability and permissions;
- wormhole visualizations must reflect current game data and rules;
- a fixed six-panel dashboard is not a product requirement;
- responsive behavior should be designed into each real workflow, not deferred as a catch-all task.

## 4. Existing project workflow guidance worth preserving

The older `SESSION_GUIDANCE.md` and draft README contain several useful process rules:
- inspect current code and history before recreating a feature;
- inspect the first-attempt backup read-only;
- copy/adapt one useful piece at a time;
- record provenance for reused code;
- verify the live rendered result, not just source files;
- work one small task at a time;
- do not commit, push or dispatch without owner authorization.

The old dispatch bootstrap language and stale absolute local paths should not be copied into new task files. Use the current agent-tasks templates and workflow rules when tasks are eventually drafted.

## 5. Source material reviewed

- `projects/galaxy-game-ui/INCREMENTAL-TASK-PLAN.md`
- `projects/galaxy-game-ui/PLANNING-AGENT-REVIEW-4-NEW-TASKS.md`
- `projects/galaxy-game-ui/SESSION_GUIDANCE.md`
- `projects/galaxy-game-ui/tasks/drafts/README.md`
- `projects/galaxy-game-ui/tasks/drafts/2026-10-23-HIGH-JSON-FIXTURE-LOADER-SYSTEMS.md`
- `projects/galaxy-game-ui/tasks/drafts/2026-10-23-HIGH-DASHBOARD-OVERVIEW-FROM-FIXTURES.md`
- `projects/galaxy-game-ui/tasks/drafts/2026-11-04-HIGH-AUDIT-WAYPOINT-JS-RECOVERY.md`
- `projects/galaxy-game-ui/tasks/drafts/2026-11-04-MEDIUM-FINALIZE-SIGNIN-BRANDING.md`
- `projects/galaxy-game-ui/tasks/drafts/2026-11-04-MEDIUM-REPLACE-LANDING-LOGO.md`
- `projects/galaxy-game-ui/tasks/drafts/2026-11-04-MEDIUM-PORT-WAYPOINT-NAVIGATION.md`
- `projects/galaxy-game-ui-first-attempt/MAIN-PROJECT-UI-RESEARCH.md`
- `projects/galaxy-game-ui-first-attempt/EVE-DASHBOARD-FOUNDATION-PLAN.md`
- `projects/galaxy-game-ui-first-attempt/CSS-INTEGRATION-STRATEGY.md`

See [First-attempt reconciliation](first-attempt-reconciliation.md) for reuse boundaries and [Prototype roadmap](prototype-roadmap.md) for the proposed planning sequence.
