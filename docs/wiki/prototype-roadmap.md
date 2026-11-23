# Prototype Roadmap and Planning Sequence

**Status:** First Admin AI Manager workflow selected and partially implemented; live API integration remains deferred  
**Last updated:** 2026-11-23

This roadmap records the current prototype sequence. It is a planning reference, not blanket authorization for backend implementation. Ordinary screen refinements are built directly in the UI prototype; substantial cross-cutting work may use reviewed Qwen task drafts.

## 1. Planning principles

- Keep the project wiki as the durable home for application direction, design decisions and rationale.
- Keep agent-tasks focused on concise, actionable work orders, review items, status and handoffs.
- Inspect the live application and current branch before describing implementation as complete.
- Preserve useful work from the first attempt, but do not inherit its mock-data architecture or stale assumptions.
- Build one vertical slice at a time and review it before expanding.
- The main GalaxyGame API is the production integration boundary; this Rails 8 prototype is an API client.
- The read-only main-game JSON mount is for local testing/source inspection only. Do not duplicate or maintain a second system-data catalog in this repository.
- Keep the prototype clearly separated from live simulation state. Mock actions must not dispatch assets or mutate the game.

## Completion Status (2026-11-23)

| Stage | Description | Status |
|-------|-------------|--------|
| Stage A — Reconcile baseline | Evidence-based snapshot of active main branch, routes/controllers, assets, and verification state | ⚠️ Partially complete |
| Stage B — Define first workflow | Admin AI Manager operational task workflow selected; initial overview/workbench prototype implemented with fixtures | 🟡 In progress |
| Stage C — Establish API/JS pattern | Replaceable in-process MockAiManagerApi exists; main-game API client and JSON loader remain deferred | 🟡 Partial foundation only |
| Stage D — Grow by workflow | Expand after the first workflow is reviewed; do not add page-by-page placeholders in parallel | ⏳ OPEN |
| Stage E — Review boundary | Reassess frontend/API versus full-app boundary from integration evidence | ⏳ OPEN |

**Stage A output:** Screenshot evidence at docs/wiki/assets/screenshots/galaxy-game-ui/ (5 screens captured), EVE reference documentation, and updated screen/workflow/porting pages. Routes and the AI Manager controllers/views have now been inspected for the first workflow. The active main branch contains an Admin AI Manager Overview, Task Workbench, Task Detail, Plan Review, Execution Monitor, and Decision Log using prototype fixtures.

**Remaining Stage A work:** Full JavaScript entry-point/Stimulus inventory, copied or adapted EVE reference-code identification, current dashboard/admin/landing/sign-in verification, local Docker/browser verification, tests and standard verification commands, remaining placeholder data sources, and comparison with the archived first attempt. These have not been completed.

## 2. Existing proposals to reconcile

The 2026-11-19 page-by-page AI Manager review drafts (Dashboard, Missions, Mission Detail, Planner, Decisions, Patterns, and Performance) are not the active implementation sequence. The first workflow is now the shared Admin AI Manager operational task workflow described below. Do not dispatch those page-specific drafts in parallel or rebuild screens that already exist on main.

The earlier Create AI Manager Inspection Workspace task exists in review/hold-for-review history. Its inspection intent is now represented by the current workbench and overview. Reconcile or supersede that task history through the normal agent-tasks review process; do not treat duplicate copies as independent active work.

Other candidate cleanup/recovery items—Waypoint JavaScript, sign-in branding, landing logo, and waypoint navigation—remain separate and must be checked against current main before any work is proposed.

## 3. Selected first workflow

### Stage B — Admin AI Manager operational task workflow

**Owner decision:** the first workflow is the Admin AI Manager operational task workflow for NPC operations, not a Player dashboard and not a general page-by-page port of the old AI Manager screens.

The first prototype slice now includes:
- system context selection using Sol/Eden fixture contexts;
- task queue and status counts;
- task detail with objective, rationale, origin, governing source, authority, target, constraints, and dependencies;
- proposed plan and resource review;
- clearly mock approve/reject/defer actions;
- execution monitor with illustrative activity;
- overview of current objectives, operating conditions, and recent decision activity;
- decision records linked back to their operational task.

The in-process MockAiManagerApi service supplies shared fixture records to the overview, decision log, and workbench. Fixture data is temporary; no live simulation is connected, no task action dispatches assets, and no game state is changed.

**Remaining workflow work:** deeper result/history presentation, realistic loading/empty/error states, decision/review state transitions within the mock boundary, and owner review of the screen hierarchy. The Player-facing view remains future work.

### Stage C — Establish the smallest production API/JavaScript pattern

The current MockAiManagerApi is an in-process prototype service, not the production integration pattern. The production boundary is the main GalaxyGame API; the UI prototype is its client.

When this stage is approved:
- inspect the main-game API/lookup services and their tests;
- define only the API contract needed by the first Admin workflow;
- replace the mock provider with an API client/adapter without unnecessarily changing the workflow views;
- test authorization, loading, empty, error, stale-data, and retry states.

The main game's read-only JSON mount remains a local development/testing aid only. A JSON loader is deferred; do not introduce a second maintained system-data catalog in the UI repository.

**Output:** one verified main-game API integration slice, not a speculative API catalog.

### Stage D — Grow by workflow and verified domain capability

Multi-system resource coordination remains post-Luna roadmap work. It must not drive or pull forward the current Admin prototype or backend architecture.

For each later workflow:
- identify the required main-game API/domain capability;
- confirm that the underlying game behavior and data contract exist;
- migrate or integrate only the needed behavior;
- preserve existing behavior and add tests;
- connect the interface through the API boundary;
- verify loading, empty, error, authorization, and normal states;
- record remaining gaps without presenting mock behavior as live.

### Stage E — Review architecture boundary as evidence accumulates

Revisit whether this repository becomes the complete application or remains the frontend/API while some game logic stays in the main app. Make this decision from operational needs and migration evidence, not in advance of the first working integration.

## 4. AI Manager architecture boundary

NPC and Player AI Managers use the same capabilities and decision/execution code. They differ through operating policy and authority:
- NPC operations follow system policy over NPC-controlled assets.
- A Player AI Manager uses the same capabilities but is limited to player-owned assets and the authority the player delegates.
- The Admin workspace supervises NPC operations and manages shared operational definitions.
- The Player-facing workspace is future work; it is not a second AI engine.

See AI Manager Missions and Task Library for the task/mission distinction, ownership rules, and prototype screen plan.

## 5. First vertical slice and data boundary

The first UI vertical slice is the Admin AI Manager operational task workflow. The initial version is deliberately mock-only and uses temporary Sol/Eden fixtures through MockAiManagerApi. It is not a live game-data reader and does not imply that backend task planning or execution is operational.

The first production API slice remains OPEN. A narrow system/body or task/target lookup may be considered only after the Admin workflow contract is reviewed.

The UI prototype's Docker mount of the main game's data/json-data directory is read-only and for local testing/source inspection. The UI application must use the main game's API for production integration. The possible presence of ignored local JSON copies is recorded in the UI project's NEEDS_REVIEW and must be inspected before any cleanup.

## 6. Decisions and current state

| Decision | Current state |
|---|---|
| First workflow and audience | **CONFIRMED:** Admin AI Manager task workflow for NPC operations |
| First screen/workspace | **CONFIRMED:** Overview + Task Workbench (queue, detail, plan review, execution monitor, decision activity) |
| First mock data/service boundary | **IMPLEMENTED:** in-process MockAiManagerApi with temporary Sol/Eden fixtures |
| First production reader/API slice | OPEN — select only after workflow review |
| JSON data access and path precedence | Main-game API for production; read-only main-data mount for local testing; JSON loader deferred |
| Reader code ownership (adapted vs shared) | OPEN until the first production API slice is selected |
| Cache lifecycle | OPEN |
| First API resource contract | OPEN |
| JavaScript interaction pattern for first production slice | OPEN |
| Admin/player application boundary | **CONFIRMED:** shared AI Manager capabilities; operating policy and authority differ |
| Long-term complete-app vs frontend/API boundary | OPEN |
| Multi-system resource coordination | Post-Luna roadmap; not part of the current prototype slice |

## 7. Task readiness and implementation workflow

Only create a formal task when the work is substantial, cross-cutting, benefits from an independent agent/review, or has dependencies that need explicit tracking.

Ordinary screen refinements for this prototype are implemented directly in the UI repository; do not create a separate formal task for every view. Use reviewed Qwen task drafts for larger implementation slices, and keep them in drafts until independent review and owner approval. Do not dispatch a draft.

A task should contain one objective, point to the relevant wiki pages, specify concrete acceptance criteria, and avoid duplicating the rationale here.

## 8. What this roadmap does not decide

This roadmap does not approve:
- a final navigation/menu structure beyond the current Admin workflow entry points;
- a final Player AI Manager screen composition;
- a frontend framework replacement;
- an API-wide design;
- a full database/model migration;
- a fixed order for StarSim, TerraSim, economy, logistics, or wormhole work;
- any new gameplay rule or operational capability.

Those require evidence and owner review.
