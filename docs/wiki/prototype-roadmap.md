# Prototype Roadmap and Planning Sequence

**Status:** Proposed planning sequence — for owner review  
**Last updated:** 2026-11-08

This is a planning map for the prototype. It is deliberately not a set of implementation tasks and does not authorize dispatch. The purpose is to clarify the work and decisions before writing task files.

## 1. Planning principles

- Keep the project wiki as the durable home for application direction, design decisions and rationale.
- Keep `agent-tasks` focused on concise, actionable work orders, review items, status and handoffs.
- Do not write task files until the relevant design and dependencies are understood and reviewed.
- Inspect the live application and current branch before describing implementation as complete.
- Preserve useful work from the first attempt, but do not inherit its mock-data architecture or stale assumptions.
- Build one vertical slice at a time and review it before expanding.
- No implementation task should imply approval to dispatch, commit or push.

## Completion Status (2026-11-08)

| Stage | Description | Status |
|-------|-------------|--------|
| Stage A — Reconcile baseline | Evidence-based snapshot of active main branch with screenshots | ⚠️ Partially complete |
| Stage B — Define first workflow | Not yet started (requires owner decision) | ⏳ OPEN |
| Stage C — Establish API/JS pattern | Not yet started | ⏳ OPEN |
| Stage D — Grow by workflow | Not yet started | ⏳ OPEN |
| Stage E — Review boundary | Not yet started | ⏳ OPEN |

**Stage A output:** Screenshot evidence at `docs/wiki/assets/screenshots/galaxy-game-ui/` (5 screens captured). EVE reference documentation at `docs/wiki/assets/screenshots/eve-dashboard/README.md` (code-derived observations). Updated wiki pages linking evidence to screen concepts and porting plans.

**Remaining Stage A work:** Routes/controllers inspection, JavaScript entry points and Stimulus controllers, copied or adapted EVE reference code identification, current dashboard/admin/landing/sign-in state verification, tests and verification commands, remaining placeholder data sources, and comparison with the archived first attempt. These have not been completed.

---

## 2. Existing near-term proposals to reconcile

The 2026-11-04 `agent-tasks/projects/galaxy-game-ui/tasks/drafts/README.md` identifies several small prototype work candidates. Their current completion state must be checked against the live `main` branch before any task is rewritten or dispatched:

| Candidate | Earlier proposal | Planning treatment now |
|---|---|---|
| Waypoint JavaScript recovery | Read-only audit of current prototype, first-attempt history and local backup | Retain as a candidate audit if the work has not already been completed. Inspect existing copied/adapted EVE JS before building a replacement. |
| Sign-in branding/presentation | Finish Galaxy Game branding while preserving Rails authentication | Re-check current sign-in page and authentication behavior; do not assume the October 30 task still describes the current defect. |
| Landing logo | Replace/align the landing logo with the selected Galaxy Game asset | Confirm current asset usage and user-approved logo direction before proposing a change. |
| Waypoint navigation | Conditional port after the audit and owner approval | Only proceed if the existing code is useful and the Galaxy Game workflow for it is understood. |

These are candidate cleanup/recovery items, not a dispatch queue. They should be reconciled with current Qwen work and the live app before becoming tasks.

## 3. Proposed planning stages

### Stage A — Reconcile the current prototype baseline

Establish one evidence-based snapshot of the active `main` branch:
- current routes, controllers, views, layouts and authentication behavior;
- current asset pipeline, Tailwind build and startup behavior;
- existing JavaScript entry points, Stimulus controllers and any copied/adapted EVE reference code;
- current dashboard/admin/landing/sign-in state;
- current tests and verification commands;
- any remaining placeholder data and its source;
- current differences from the archived first attempt.

**Output:** an updated verified baseline in this wiki. Do not repeat the earlier audit's unverified recommendations as decisions.

### Stage B — Define the first interface workflow

Choose the first workflow based on user value and the state of the prototype. Record:
- audience (player or admin);
- goal and user context;
- screen or workspace responsibilities;
- data required and authoritative source;
- actions and permissions;
- loading, empty, error and stale-data states;
- dependencies on game intent or unimplemented domain behavior.

Do not assume the first workflow must be a six-panel player dashboard. The current prototype already has distinct admin and player concerns to evaluate.

**Output:** a reviewed workflow/screen definition in the wiki.

### Stage C — Establish the smallest API/JavaScript pattern

After current UI work is committed or explicitly paused:
- inspect the main-game lookup services and their tests;
- resolve only the reader/data-path decisions needed for the chosen workflow;
- implement a narrow reader slice;
- expose one application-level Rails API resource;
- request it from JavaScript and render it in an existing view;
- test behavior, authorization, error and empty states.

**Output:** a proven integration pattern, not a speculative API catalog.

### Stage D — Grow by workflow and verified domain capability

For each next workflow:
- identify the required model/service/data source;
- migrate or integrate only the needed behavior;
- preserve existing behavior and add tests;
- define an application API contract;
- connect the interface;
- verify the rendered workflow and record remaining gaps.

Possible domains include systems and celestial bodies, assets/inventory, economy/market, research/manufacturing, settlements/infrastructure, logistics, StarSim, TerraSim and wormholes. This list is not an order.

### Stage E — Review architecture boundary as evidence accumulates

Revisit whether this repository becomes the complete application or remains the frontend/API while some game logic stays in the main app. Make this decision from operational needs and migration evidence, not in advance of the first working integration.

## 4. Screen and JavaScript planning references

The screen concepts and wireframes are maintained in [Screen Concepts and Low-Fidelity Wireframes](screen-concepts-and-wireframes.md). They describe candidate player home, contextual selectors, system map, celestial-body inspection, assets, market, research/industry, settlement/logistics, and Admin Console workspaces. These are proposals; the first workflow and final layouts remain OPEN.

The JavaScript reuse plan is maintained in [JavaScript Reuse, Porting, and Module Plan](javascript-reuse-and-porting-plan.md). It maps fleet_map.js, market.js, chain.js, assets.js, wealth.js, and structures.js to candidate reuse/adaptation, and identifies application context, API client, data adapters, and celestial-body interaction as Galaxy Game-specific responsibilities. Existing prototype copies must be recovered before any port is started.

These pages are intended to become the design references that future agent-tasks work orders link to. Do not duplicate their rationale in task files.

The [Visual Reference and Screenshot Documentation Plan](visual-reference-and-screenshot-plan.md) defines how Qwen should capture the current prototype, document EVE Dashboard navigation/workspaces and the six supplied JS references, and connect evidence back to the screen and porting plans. Screenshots are evidence, not automatic design approval.

## 5. Candidate first vertical slice

A candidate foundation is a small read-only flow involving basic game data. Galaxy → SolarSystem → CelestialBody is one possible model sequence. Blueprint and unit lookup services are another candidate if the first selected workflow needs them.

No candidate is approved yet. Selection criteria:
1. it supports a real workflow already chosen for the prototype;
2. source data and current behavior are understood;
3. it exercises the reader/API/JavaScript boundary without requiring a broad migration;
4. it can be tested end to end;
5. it avoids locking unresolved game rules into the interface.

## 6. Decisions to settle before task drafting

| Decision | Current state |
|---|---|
| First workflow and audience | OPEN |
| First screen/workspace | OPEN |
| First reader/service slice | OPEN |
| JSON data access and path precedence | OPEN |
| Reader code ownership (adapted vs shared) | OPEN |
| Cache lifecycle | OPEN |
| First API resource contract | OPEN |
| JavaScript interaction pattern for first slice | OPEN |
| Admin/player application boundary | OPEN in detail; keep purposes distinct |
| Long-term complete-app vs frontend/API boundary | OPEN |
| Migration sequence beyond first slice | OPEN |
| Wireframe navigation labels (illustrative vs proposed) | OPEN — screen-concepts wireframes use illustrative labels; whether they represent proposed navigation is undecided |
| API response and error conventions | OPEN — no documented contracts yet |
| API authentication and CSRF behavior | OPEN — existing prototype authentication is present; integration details need design |
| Standard test and verification commands for the prototype | OPEN — not yet documented |

## 7. Task readiness gate

Only draft an implementation task after:
- the target outcome is agreed;
- relevant wiki decisions and domain sources are identified;
- current code paths and names are verified;
- scope and exclusions are explicit;
- dependencies are real and current;
- acceptance criteria can be demonstrated;
- the task does not duplicate work already in the current branch;
- the required verification environment is known.

A task should contain one objective, point to the relevant wiki pages, specify concrete acceptance criteria and avoid duplicating the rationale here. Use `status: draft` under the current agent-tasks conventions. Do not add dispatch instructions to a draft.

## 8. What this roadmap does not decide

This roadmap does not approve:
- a final navigation/menu structure;
- a fixed player dashboard composition;
- a frontend framework replacement;
- an API-wide design;
- a full database/model migration;
- a fixed order for StarSim, TerraSim, economy, logistics or wormhole work;
- any new gameplay rule or operational capability.

Those require evidence and owner review.
