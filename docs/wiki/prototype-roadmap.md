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

## 2. Proposed planning stages

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

## 3. Candidate first vertical slice

A candidate foundation is a small read-only flow involving basic game data. Galaxy → SolarSystem → CelestialBody is one possible model sequence. Blueprint and unit lookup services are another candidate if the first selected workflow needs them.

No candidate is approved yet. Selection criteria:
1. it supports a real workflow already chosen for the prototype;
2. source data and current behavior are understood;
3. it exercises the reader/API/JavaScript boundary without requiring a broad migration;
4. it can be tested end to end;
5. it avoids locking unresolved game rules into the interface.

## 4. Decisions to settle before task drafting

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

## 5. Task readiness gate

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

## 6. What this roadmap does not decide

This roadmap does not approve:
- a final navigation/menu structure;
- a fixed player dashboard composition;
- a frontend framework replacement;
- an API-wide design;
- a full database/model migration;
- a fixed order for StarSim, TerraSim, economy, logistics or wormhole work;
- any new gameplay rule or operational capability.

Those require evidence and owner review.
