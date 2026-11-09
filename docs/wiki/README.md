# Galaxy Game UI — Project Wiki

**Status:** Initial project direction — evolving  
**Last updated:** 2026-11-08  
**Repository:** `trmccormick/galaxy-game-ui`  
**Purpose:** Canonical project reference for the application being built in this repository.

This wiki records what the Galaxy Game UI application is intended to become, its current architecture direction, interface principles, migration approach, implementation baseline, and unresolved decisions. It is separate from the `galaxyGame` domain wiki and from the actionable work orders in `agent-tasks`.

---

## 1. What belongs in this wiki

The three documentation homes have different responsibilities:

| Location | Responsibility |
|---|---|
| `docs/wiki/` at the repository root | This application's purpose, UI and application architecture, API/JavaScript direction, interface decisions, migration strategy, implementation progress, and rationale |
| `galaxyGame/docs/wiki/` | Galaxy Game domain, simulation behavior, game mechanics, established gameplay intent, and authoritative game-data meaning |
| `agent-tasks/projects/galaxy-game-ui/` | Slim actionable tasks, review items, status bookkeeping, and session handoffs; these point back to this wiki rather than becoming a parallel design specification |

The prototype wiki is authoritative for decisions about this application. The main game's wiki remains authoritative for game-domain facts and established game behavior. Where an interface decision depends on a game rule, use the main game's wiki and current code/data as the domain sources, then record the resulting application/interface decision here.

Tasks describe what to do and how completion will be checked. They should not repeat the design rationale maintained here.

## 2. Project purpose and direction

### ESTABLISHED INTENT — 2026-11-08

The prototype is becoming the foundation of the new Galaxy Game interface. It is not intended to remain a disconnected visual mockup.

The goal is to develop the new interface in this separate application, establish its presentation and interaction patterns, and progressively connect it to real Galaxy Game data and backend behavior. As integrations are proven, prototype screens and placeholder behavior can be replaced with real application workflows.

### DIRECTION

- JavaScript is the primary presentation and interaction layer for the user interface.
- Rails provides the application backend and API: authentication and authorization, access to game data, validation, application/domain services, persistence and transactions, game rules and calculations, and future simulation/operations integration.
- The API should expose application-level resources and consistent contracts. It should not be designed as a thin pass-through that merely returns arbitrary source JSON files.
- Existing Galaxy Game behavior should be ported and reused where appropriate, not independently recreated. Preserve behavior first; optimization and refactoring are separate work.
- Development should proceed incrementally, proving the integration pattern with small vertical slices before moving larger systems.
- The application should evolve around actual player workflows. Do not build a large speculative API or migrate every backend subsystem before the interface needs it.

### Superseded earlier description

Older project notes describe this as an appearance-only prototype using placeholder data, with no live game integration or backend functionality. That described an earlier phase. The direction above, confirmed by Tracy on 2026-11-08, supersedes that limitation. Preserve useful work from the earlier phase, but do not treat its no-integration statement as the current target.

## 3. Intended application architecture

### DIRECTION — logical responsibilities

**JavaScript frontend**

JavaScript is expected to own the interactive presentation experience, including:

- application navigation and contextual navigation;
- dashboards and dynamic workspaces;
- maps and spatial/network visualizations;
- tables, charts, filtering, sorting, and search;
- client-side selection and interaction state;
- incremental updates to displayed information;
- interactive controls that invoke backend operations through application APIs.

**Rails backend**

Rails remains responsible for authoritative application behavior, including:

- authentication and authorization;
- API endpoints and response contracts;
- access to Galaxy Game data;
- application and domain services;
- validation and enforcement of game rules;
- persistence, transactions, and durable state;
- calculations and future simulation/operations integration.

The frontend may manage transient presentation state, but it must not become a second authority for game rules or durable game state.

### Initial data flow

The intended starting flow is:

```
Galaxy Game JSON data
        |
        v
Prototype JSON reader
        |
        v
Rails API
        |
        v
JavaScript interface
```

The prototype JSON reader is to be built in this repository. There is no existing prototype reader to expose through an API.

The reader should begin by porting/adapting the main game's existing lookup-service behavior. It should provide a controlled application-side way to load and query game data. The API then exposes the relevant data through deliberate resources and contracts, and JavaScript requests and renders it.

This is an initial integration path, not a claim that all future game data must permanently flow through JSON. As actual models and services are migrated into the application, the API can use those authoritative sources while retaining stable response contracts where practical.

### Progressive backend migration

Over time, real models, services, and simulation systems from the main game may be ported into this application in stages. Each stage should preserve existing behavior and be verified before dependent UI workflows are moved over.

Potential areas include basic game models and lookup/data services first, followed later by larger subsystems such as StarSim, TerraSim, economy, settlements, logistics, wormholes, and simulation/operations. This list is a scope map, not an approved migration sequence.

The long-term application boundary is still open: the prototype may ultimately become the complete application, or it may remain a frontend/API application while some game logic continues to live in the main game. Do not assume that boundary has been settled.

## 4. Existing implementation baseline

The following is a repository-read snapshot of the clean prototype line as inspected on 2026-11-08. That line has since been renamed to the repository's active `main` branch. It describes what was inspected at that snapshot, not a guarantee about uncommitted local work or later changes.

### Verified application foundation

- Rails 8.1 application.
- Propshaft asset pipeline.
- Importmap for JavaScript modules.
- Turbo and Stimulus are present.
- Tailwind CSS 4 is integrated through `tailwindcss-rails`.
- PostgreSQL adapter and Active Record are included in the Rails application.
- The inspected Gemfile contains no separate JavaScript package manifest or frontend build framework.
- The JavaScript entry point imports Turbo and the Stimulus controllers.
- Existing routes include session/password routes, a landing page, dashboard, about page, and an admin dashboard namespace.
- The inspected dashboard is server-rendered through an ERB/Rails controller and uses placeholder data.
- The app currently has no API namespace or prototype JSON reader in the inspected branch.
- The app does not yet have access to the main repository's `data/json-data` tree.

The presence of Active Record and PostgreSQL dependencies does not, by itself, establish which game-domain models or persistence workflows have been implemented in the prototype.

### Current UI status

The repository has a working visual foundation and is being developed as a prototype. Branding, CSS/Tailwind setup, layout shell, landing/sign-in work, and dashboard work have been handled in earlier implementation sessions. Treat the current checked-out branch and rendered application as the evidence for what is actually complete; older status notes and task checklists may be stale.

**Screenshot evidence:** Visual documentation of the current prototype is available at `assets/screenshots/galaxy-game-ui/README.md`. Five screens were captured on 2026-11-08 from the running application: landing page (signed-in), sign-in page, player dashboard, admin console, and about page. All data shown is mock/placeholder.

The current page structure, component choices, and visual design remain subject to review. The architecture direction in this wiki does not freeze a final navigation scheme, page layout, visual system, or frontend framework.

## 5. Game-data reader and lookup-service port

### Verified main-game starting point

The main `galaxyGame` repository contains lookup services under:

`galaxy_game/app/services/lookup/`

The inspected services include `BaseLookupService`, `BlueprintLookupService`, and `UnitLookupService`. The lookup layer reads JSON files, provides lookup/search behavior, and uses class-level caches in several services.

The main game also defines `GalaxyGame::Paths` in `config/initializers/game_data_paths.rb`. The path configuration supports `GALAXY_JSON_DATA_PATH` and otherwise falls back to an application data directory. The base lookup service also initializes an instance data path directly from `Rails.root/app/data`. Subclasses use the path constants for their specific data locations. These details need to be reconciled deliberately during the port rather than copied without inspection.

### DIRECTION — initial port approach

A reasonable first slice to investigate is:

1. the path configuration needed by the reader;
2. `BaseLookupService` behavior;
3. `BlueprintLookupService`;
4. `UnitLookupService`.

This is a proposed starting slice, not a locked task or final migration order. Inspect the full services and their specs before implementation. Preserve observable lookup behavior and error handling; add focused tests in the prototype. Avoid silently changing cache lifetime, path precedence, or lookup matching semantics.

### Open reader decisions

- Whether the reader is a direct copy/adaptation or shares code with the main application.
- How the prototype receives access to the main repository's JSON data (for example, a mounted data directory or configured path).
- How `GALAXY_JSON_DATA_PATH` and the main lookup services' existing path behavior should be handled.
- Whether process-lifetime class-level caches are retained, changed, or made explicitly refreshable.
- Which lookup services are needed for the first useful UI/API slice.

These decisions should be made from code inspection and a small tested implementation, not from assumptions.

## 6. Interface and navigation principles

### DIRECTION

The interface should make important destinations discoverable and quick to reach. It should not translate the game's underlying database/domain hierarchy directly into a deeply nested sidebar.

Use the EVE Online dashboard/navigation approach as a reference for information architecture: accessible global destinations, contextual selectors, page-level content, and feature-specific secondary navigation. Relationships such as galaxy → star system → celestial body can be represented through selectors, page content, maps, or contextual navigation when relevant; they should not automatically become nested primary-menu levels.

The interface should reflect the player's current context without hiding useful global destinations. Features such as economy, research, and missions should be presented according to their actual player workflows and domain scope, not assigned a global or settlement-only location by assumption.

### Existing Galaxy Game experience to preserve and adapt

The main game has existing views and interaction concepts for the solar-system view and celestial-body inspection. The celestial-body experience includes Monitor, Planetary, and Surface layers. These are useful sources for understanding what information the player can inspect and how the world is represented. The new interface should preserve useful capabilities and domain meaning while improving presentation and interaction; it should not discard them merely because the prototype uses a different layout.

The visual design is still being worked out. The current prototype's dark blue/gray and cyan direction is a working implementation direction, not a final locked palette unless separately approved. Do not treat placeholder colors, fixture values, or old screenshots as authoritative design decisions.

### Interface references

EVE-derived JavaScript files reviewed as references include:

- `fleet_map.js`: interactive SVG map, pan/zoom, routes, markers, tooltips, context menus, and shortest-path logic;
- `market.js`: searchable/filterable market table, sorting, summary metrics, and refresh behavior;
- `chain.js`: interactive network map, editing interactions, zoom/pan, link state, and contextual information;
- `assets.js`: multiselect filters, select-all/none, indeterminate state, and typeahead;
- `wealth.js`: interactive analytics chart, grouping, filters, shared selection, and transaction drill-down;
- `structures.js`: delegated clipboard actions and feedback.

These are design/implementation references, not code to transplant wholesale. EVE-specific concepts, endpoints, data models, and assumptions must be replaced with Galaxy Game equivalents. Recover and inspect any previous copied/adapted JavaScript in the prototype before starting a new port.

## 7. Migration and implementation approach

### DIRECTION

1. Keep improving the existing prototype rather than restarting it.
2. Inspect what is already present in the current branch and recover useful earlier work before creating replacements.
3. Establish the frontend/API integration pattern with one small vertical slice: a real endpoint backed by the prototype reader, a JavaScript request, and a dynamic display in an existing prototype view.
4. Verify that slice end to end before expanding it.
5. Port basic models and services incrementally, preserving behavior and testing each migration.
6. Move larger simulation and operational subsystems only when their dependencies and required workflows are understood.
7. Replace placeholder UI data with real API-backed data as each integration is proven.
8. Keep refactoring and performance optimization separate from behavior-preserving ports.

Do not begin a broad backend migration, build a speculative API surface, or redesign the entire frontend framework as a prerequisite to the first vertical slice.

The first end-to-end API/JavaScript slice should wait until the current Qwen UI work has been committed or explicitly paused and its state is reviewed. This avoids overlapping implementation work.

## 8. Decisions and questions still open

The following are intentionally unresolved. This wiki records them so future sessions do not accidentally treat a proposal as a decision.

| Topic | Current position |
|---|---|
| Final application boundary | OPEN — complete app versus frontend/API with some game logic remaining in the main app |
| Reader code ownership | OPEN — copy/adapt versus shared code |
| JSON data access | OPEN — mount, configured path, or another supported mechanism |
| Lookup path precedence | OPEN — reconcile `BaseLookupService` and `GalaxyGame::Paths` behavior |
| Cache behavior | OPEN — preserve or change process-lifetime caches |
| Frontend framework | OPEN — existing Hotwire/importmap foundation is present; no replacement framework is selected |
| Final navigation and page structure | OPEN — evolve through reviewed workflows and prototypes |
| Visual tokens and accent color | OPEN unless confirmed in a later design review |
| Model/service migration order | OPEN — basic foundations first is the direction; exact sequence is not locked |
| API resource design | OPEN — design around concrete workflows and stable application contracts |
| Authentication and authorization integration | OPEN — existing prototype authentication is present; game-specific permissions and account integration need design |

When a decision is made, update this wiki with the date, decision, and scope. If a proposal is not approved, keep it labelled as a proposal or OPEN.

## 9. Detailed planning pages

The following pages expand the initial direction without turning it into implementation tasks:

- [Interface and workflow direction](interface-and-workflows.md) — player/admin distinction, navigation principles, context, world-inspection capabilities and data age.
- [Data integration and backend migration](data-integration-and-migration.md) — JSON reader, lookup-service port, Rails API, JavaScript integration and progressive migration.
- [First-attempt reconciliation](first-attempt-reconciliation.md) — what can be reused, what is superseded, and lessons from the earlier task sequence.
- [Legacy task reconciliation](legacy-task-reconciliation.md) — maps older `agent-tasks` proposals to the current prototype direction.
- [Interface pattern references](interface-pattern-references.md) — EVE Dashboard, EVE Tycoon, EVEpraisal and reusable JavaScript interaction patterns.
- [Prototype roadmap](prototype-roadmap.md) — proposed planning stages and the gate to pass before task drafting.
- [Screen concepts and wireframes](screen-concepts-and-wireframes.md) — proposed player/admin workspaces, low-fidelity screen sketches, shared interaction requirements, and open design decisions.
- [JavaScript reuse and porting plan](javascript-reuse-and-porting-plan.md) — which shown EVE JS files may be adapted, what should be newly built, and a proposed module/porting sequence.
- [Visual reference and screenshot plan](visual-reference-and-screenshot-plan.md) — Qwen capture guidance, screenshot manifests, Galaxy Game visual baseline, and EVE Dashboard documentation plan.

These are working proposals and reference documents. They do not authorize implementation or dispatch; open questions remain open until Tracy confirms them.

## 10. Working rules for future changes

- **Code and data define current implementation.** This wiki records intended direction and decisions; it must not claim a feature exists merely because it is planned.
- **Owner-confirmed intent controls design.** If current code conflicts with an established decision, report the gap rather than silently changing the design to match the code.
- **Label evidence.** Use VERIFIED for facts checked against a named branch/commit or inspected source, REPORTED for information supplied by a person or earlier report, DIRECTION for current but revisable direction, and OPEN for undecided matters.
- **Keep tasks thin.** Each task should point to the relevant wiki section, state one objective, and define acceptance criteria. Put design rationale here, not in a duplicate task specification.
- **Preserve behavior before refactoring.** Port existing behavior and prove parity before optimizing or redesigning it.
- **Review rendered results.** Interface changes require checking the running application, not just reading ERB or CSS.
- **Do not infer game rules from fixtures.** Placeholder values and mock data are not authoritative game data or approved gameplay decisions.
- **Do not duplicate the main game's domain wiki.** Link or refer to its domain topics where appropriate; keep this wiki focused on the new application's design and implementation.

---

## Change history

- **2026-11-08** — Initial project wiki created. Records the owner-confirmed shift from an appearance-only prototype to the foundation of the new Galaxy Game interface, with JavaScript as the primary presentation layer and Rails as the API/application backend.
- **2026-11-08** — Added interface/workflow, data integration/migration, first-attempt reconciliation and prototype roadmap pages after reviewing the earlier UI task plans and first-attempt guidance. These pages are proposals for review, not implementation authorization.
- **2026-11-08** — Added a reference-pattern guide and a task-by-task reconciliation of earlier `agent-tasks` proposals. Old task statuses and branch-specific paths remain subject to live verification before any task is drafted.
- **2026-11-08** — Added low-fidelity player/admin screen concepts and a JavaScript reuse/porting plan. Wireframes and module sequence are proposals, not final UI or implementation authorization.
- **2026-11-08** — Added a visual-reference and screenshot plan for Qwen, covering current-prototype evidence capture and structured EVE Dashboard documentation.
