# Data Integration and Backend Integration Proposal

**Status:** PROPOSAL — for review; not yet adopted or implemented  
**Last updated:** 2026-11-11  
**Scope:** JSON data access, Rails API responsibilities, JavaScript integration and progressive migration from the main game.

## 1. Immediate prototype data approach

**CURRENT PROTOTYPE SCOPE — temporary data supply for design and API discovery**

The prototype does not need a production API integration to proceed. First get the existing view JavaScript, renderers, dashboard components, and assets in place. Feed them imported JSON from the main GalaxyGame application where available, or clearly identified mock JSON where necessary.

Both imported and mock data should exercise the same presentation code. Keep the source of each dataset explicit (imported/harvested, mock, or eventually live API). Do not build a new reader or data framework until inspection shows the existing prototype/main-app reader approach cannot serve the immediate purpose.

For each view, record:
- the existing source files, data files, and assets used;
- the data shape the JavaScript currently expects;
- any small adapter or compatibility mapping required;
- fields or relationships that are absent from the existing data;
- which values are mocked and why;
- what a future main-game API would need to supply.

This is evidence gathering for future API design, not an API contract. Mock fields must not silently become requirements or be presented as established game mechanics. The prototype is not expected to implement authoritative simulation operations or production backend behavior.

### System source data and landing-page loading — do not make completeness a gate

The prototype should load and display the system records actually made available to it. Do not assume a permanent five-system catalog, a fixed number of records, or fixed generated-system identifiers/filenames. Early procedural, hybrid, or sparse real-system data is acceptable as provisional source material. Do not hold up the landing page, system navigation, or view-porting while every property is scientifically refined or every system has been surveyed. Preserve stable object identity and available provenance; label preliminary/incomplete data honestly. Correct structural defects only where they break identity, selection, or relationships required by the current UI task.

**Important game-domain boundary:** a system JSON file is starting information, not necessarily a complete playable system or exhaustive inventory. Sol is the only fixed, manually authored baseline, but its representation is incomplete and StarSim may add objects/details there too. Every other system begins with incomplete information, whether extensive known real-system data, sparse known data, or generated starting conditions. StarSim uses the available information to complete and populate a playable system; its output is not necessarily exhaustive. Survey missions help add newly discovered objects and details over time and may support further spawning/addition. Keep simulated world state, supplied starting information, and discovered/recorded knowledge distinct. Exact spawning, discovery, visibility, and persistence mechanics belong to the evolving main-game implementation and must not be invented by this prototype.

The later game-domain work for StarSim completion, survey observations/discoveries, property refinement, calibration/reconciliation, and active map/body updates is recorded in the authoritative main GalaxyGame wiki, especially `galaxyGame/docs/wiki/astronomy/system_blueprints.md`, `galaxyGame/docs/wiki/design/starsim_and_protection_classes.md`, and `galaxyGame/docs/wiki/services/ai_manager.md`. It is not part of the landing-page loader's responsibility and is not a prerequisite for this prototype task. The prototype should consume available data and record genuine display/integration gaps; it must not perform scientific corrections, system generation, or survey simulation itself.

### Sol system fixtures and celestial-object data

The prototype's copied JSON data is organized under its top-level `json-data/` directory. The corresponding main-app source tree is `data/json-data/`:

- Main app: `data/json-data/star_systems/` and `data/json-data/generated_star_systems/`
- Prototype copy: `json-data/star_systems/` and `json-data/generated_star_systems/`

These are the current directory roles, not a finalized taxonomy. The main app's `star_systems/` currently contains Sol and real-system starting records with varying levels of completeness; non-Sol records are incomplete inputs for StarSim, not complete playable systems. The generated directory contains generated/completed outputs and fixtures, which are also not guaranteed exhaustive inventories. The organization may be tuned later after the generator, lookup/loading paths, provenance needs, and UI discovery behavior are better understood. Do not reorganize or migrate these directories as part of prototype data-loading work.

The Sol fixtures are intentionally different in breadth:

- **`star_systems/sol.json`** is a smaller sample of Sol's celestial objects. It already includes major worlds such as Earth, Mars, Venus and Titan, alongside other objects. It is useful for ordinary UI development and for testing views against a smaller object collection.
- **`star_systems/sol-complete.json`** is the fuller Sol celestial-object collection. Use it when testing larger system catalogs, object counts, navigation and selection across the broader collection.

These are separate, intentional fixtures—not a broken/incomplete file that should be merged into the fuller one. Preserve both unchanged. `sol-complete.json` is fuller relative to `sol.json`; neither should be described as a complete or exhaustive inventory of the real or simulated Sol system. StarSim and later survey activity may add further objects/details.

**Important data boundary:** these star-system JSON files describe star systems and celestial objects. They do not contain terrain. Do not describe either Sol fixture as a terrain/map dataset, and do not make terrain loading, terrain-map completeness, or map generation a prerequisite for the landing page or this initial JSON-backed UI work. Terrain and terrain assets are separate data concerns for the relevant later views.

The prototype has also been supplied with generated-system JSON under `json-data/generated_star_systems/`. These are genuine generated system records, not mock entries. Treat the records actually supplied as available UI data; do not require new StarSim generation or scientific refinement to display them. They are generated/completed snapshots, not final exhaustive system inventories. The main game may continue to add or refine system detail through StarSim and survey activity, but the prototype must not correct, regenerate, or rewrite those records. Their existence in the data tree does not by itself establish that a system is currently accessible to a player.

The Sol, Alpha Centauri, FR-488530, DJEW-716790, and Eden-candidate (`AOL-732356`) records discussed during prototype work were actual JSON data available at that time, including generated records—not mock system definitions. That set was simply a snapshot of the records then present, not a permanent five-system product contract or a statement that all five were continuously accessible. Alpha Centauri demonstrates a known-real-system input completed by StarSim: `star_systems/alpha_centauri.json` is the known-data seed, while its hybrid generated output is a separate artifact. Eden is a replaceable generated instance selected for its role/requirement (better terraforming targets than Sol), not a permanent identifier. FR-488530 and DJEW-716790 are generated examples that may be replaced. Do not hard-code any non-Sol filename or identifier as a permanent system identity or acceptance criterion unless a later explicit decision establishes that requirement.

The public landing page should obtain its system list and current connectivity/accessibility state dynamically from authoritative application data/services as the integration path is established. Sol is the fixed baseline; the remaining system set can grow or change. System existence and route availability are separate: a known/generated system may exist in application records without currently being reachable.

The wormhole network itself is dynamic by design. Natural wormholes can shift over time, changing their positions and connections. Artificial wormholes can be shut down and retargeted, changing the route network deliberately. The landing page/network view must reflect current authoritative connection state rather than a static topology, historical route list, or hard-coded edges. Do not infer reachability from a system JSON file or from the fact that a connection was previously known/configured. Exact connection-state fields, update cadence, and route-history behavior remain to be designed from the main application's evolving implementation.

System cards and displayed object counts should be derived from actual system records, not duplicated as hand-authored mock definitions. Preserve source identifiers and parent/child relationships so separate celestial objects remain separately selectable even when preliminary generated records need later data-quality work.

Use `sol-complete.json` when the landing page should represent the fuller Sol celestial-object collection. Keep `sol.json` as the smaller sample fixture; it is also valid for UI testing because it already includes Earth, Mars, Venus, Titan and other major objects. Both fixtures are useful for testing different collection sizes. The loader should be able to select the intended Sol fixture without conflating their contents. This is a display/data-access task only: no terrain, simulation, survey, calibration, or StarSim generation behavior belongs in the prototype loader. Do not infer that the selected fixture contains every object that exists or that the UI's loaded list is the player's discovered catalog.

## 2. Longer-term API direction (still to be designed)

The main GalaxyGame application is expected to remain authoritative for game state, domain behavior, calculations, validation, persistence, authorization, and operations. The prototype can help reveal what information and actions its screens need, but endpoint names, response schemas, authentication, update cadence, and integration approach must be designed later from inspected main-app services and reviewed UI workflows. No production API work is required to make the current prototype useful.

### Prototype UI client

The prototype is the presentation and interaction layer. It handles navigation, contextual selection, dashboards, maps, tables, charts, filtering, sorting, search, transient UI state and incremental display updates.

It requests game data and permitted operations from the main application's API. It may use clearly labeled mock data while a screen is being designed, but mocks are not live state or API contracts.

### Main GalaxyGame application and API

Under the proposal, the main application would expose the game capabilities required by the UI through deliberate, documented API endpoints and response contracts. It would remain responsible for:
- authentication and authorization;
- authoritative game state and controlled data access;
- application and domain services;
- validation and enforcement of game rules;
- persistence and transactions;
- calculations and simulation/operations behavior;
- authorization and execution of state-changing operations.

The proposed API would expose resources and workflows designed for the UI, reusing existing main-app services and data access. It should not merely return arbitrary source JSON files as an unstructured pass-through.

The API surface must be inspected and built incrementally; this document does not claim that the required endpoints already exist.

## 3. Proposed data path

```text
Main GalaxyGame application
  ├─ authoritative models, services, calculations and game data
  └─ application API (documented resources and operations)
                 ↓
       Separate prototype UI client
                 ↓
       JavaScript presentation and interaction
```

Under this proposal, the main application would remain the source of truth. Its API would call or adapt existing application services and lookup behavior as appropriate, then return stable response contracts for the prototype. The prototype should consume those contracts rather than independently reading the main application's private data tree or copying its domain logic.

For early visual development, the prototype may temporarily use mock fixtures or local JSON. Keep that path explicitly separate from the live API client so that switching to real data does not require rewriting the screen and so mock assumptions do not silently become backend requirements.

If adopted, this would replace the earlier prototype-owned JSON-reader-first integration sketch. Existing lookup services remain important because they may supply the main application's API implementation; they are not a reason to duplicate a reader in the prototype.

## 4. Initial existing-view data and asset findings

**SOURCE INSPECTION — 2026-11-13; not runtime verification**

The current main-app source contains a useful starting point for direct JSON-fed ports:

### Planetary

- View: `galaxy_game/app/views/admin/celestial_bodies/planetary.html.erb`
- Renderer: `galaxy_game/app/javascript/admin/monitor.js`
- The ERB view embeds JSON in a `<script type="application/json" id="monitor-data">` element. Its payload includes body identity, temperatures, atmospheric data, terrain data, planet/sphere attributes, layer-availability flags, and civilization features.
- `AdminMonitor.init()` reads that embedded JSON and expects the existing page elements, including `#planetCanvas` and `#canvasWrapper`.
- **Porting dependency to inspect:** the renderer also polls `/admin/celestial_bodies/:id/sphere_data` every five seconds. A static JSON/mock-data prototype must either supply an appropriate local fixture/update path or isolate this polling so the renderer can demonstrate from the imported snapshot alone. Do not make a production endpoint a prerequisite.

### Surface

- View: `galaxy_game/app/views/admin/celestial_bodies/surface.html.erb`
- Renderer: `galaxy_game/app/assets/javascripts/surface_view.js`
- Supporting renderers: `biome_renderer.js` and `terrain_tile_renderer.js`, with `simple_tileset_loader.js` also present in the main app.
- The ERB view embeds JSON in `#surface-data`, including body identity, `terrain_data`, `planet_data`, tileset name, and layer availability. It also sets `window.PLANET_NAME` and `window.PLANET_TYPE`.
- Current asset references include `/tilesets/galaxy_game/biomes.json`, the configured biome `asset_path` (falling back to `/api/assets/biomes/`), and terrain images under `/api/assets/terrain/`.
- The prototype will need the existing configuration and image assets at compatible static paths, or a small configurable base-path adjustment. This is asset delivery support, not a new tileset or renderer.
- Surface initialization is registered for both `DOMContentLoaded` and Turbo navigation; verify lifecycle behavior in the prototype rather than assuming it is already safe under every navigation pattern.

These source findings identify the JSON boundary and asset dependencies to preserve. They do not diagnose the previously observed Earth/Mars tile-loading problems or prove that the views currently work at runtime. The original data and image assets must be checked in the local main-app data tree; uncommitted JSON is not expected to appear in GitHub.

## 5. Main-game lookup services: candidate starting point

The main repository has lookup services under:

`galaxy_game/app/services/lookup/`

The inspected code includes `BaseLookupService`, `BlueprintLookupService` and `UnitLookupService`, among other lookup services. The layer reads JSON, provides lookup/search behavior and uses class-level caching in several services.

The main application also defines `GalaxyGame::Paths` in `config/initializers/game_data_paths.rb`. The initial inspection identified a path-handling difference that must be understood before porting:
- `GalaxyGame::Paths` supports `GALAXY_JSON_DATA_PATH` and a fallback;
- `BaseLookupService` initializes an instance data path from `Rails.root/app/data`;
- subclasses also use path constants for their specific data locations.

A reasonable first code slice to investigate is path configuration, `BaseLookupService`, `BlueprintLookupService` and `UnitLookupService`. This is a recommendation, not an approved task sequence. Read the complete implementations and specs before deciding the exact slice.

## 6. Reader design questions

Resolve these through code inspection and a small tested implementation, not by assumption:

1. **Ownership:** copy/adapt the lookup code into this app, or establish a shared library/package? No choice is final.
2. **Data location:** how will the prototype receive the main repository's `data/json-data` tree (configured path, mounted directory, or another supported arrangement)?
3. **Path precedence:** reconcile `GALAXY_JSON_DATA_PATH`, `GalaxyGame::Paths` and the base service's Rails-root behavior.
4. **Cache semantics:** preserve process-lifetime class caches, add explicit refresh/invalidation, or use another lifecycle? Do not change semantics accidentally.
5. **Error behavior:** preserve useful missing-file, malformed-data and lookup error behavior while making API failure responses deliberate.
6. **First useful data:** which reader/service is required for the first actual screen and endpoint? Do not port every lookup service up front.

## 7. First vertical slice

If the proposal is adopted, the first API/JavaScript integration should prove one complete path:

1. Read a real, relevant game-data source through the prototype reader.
2. Expose it through one Rails endpoint with a deliberate application-level response contract.
3. Request it from JavaScript.
4. Render it dynamically in an existing prototype view.
5. Verify success, empty and error behavior, authentication/authorization as applicable, and tests.

The candidate first data domain is not locked. Basic models and lookup data are sensible foundations, and Galaxy → SolarSystem → CelestialBody is one possible sequence, but the first slice should be chosen from the current UI workflow and inspected source data.

Do not start this slice until the current UI work is committed or explicitly paused and reviewed. Do not overlap a substantial Qwen UI implementation with a new integration track.

## 8. Progressive migration

Potential future migration areas include:
- basic game entities and lookup/data services;
- celestial-body and system inspection;
- inventory, assets and player workflows;
- economy and market;
- settlements and infrastructure;
- logistics and transportation;
- StarSim and TerraSim;
- wormholes and inter-system systems;
- simulation and operations.

This is a map of possible areas, not a sequence or a commitment to migrate all of them. Move a subsystem when an actual workflow needs it and dependencies are understood.

For each migration:
- inspect the current main-game implementation and tests;
- preserve observable behavior first;
- move a narrow, testable slice;
- verify parity and edge cases;
- connect the API and UI only after the backend slice is understood;
- refactor or optimize separately from the behavior-preserving port.

## 9. Application/API boundary

The proposal is that the main GalaxyGame application exposes the API and the prototype consumes it. This has not yet been adopted as the implementation architecture.

The exact API namespace, endpoint inventory, authentication flow, response schemas, versioning strategy, and deployment topology remain OPEN. Start with a small API surface shaped by reviewed UI workflows. Keep domain logic and authoritative state in the main application.

A targeted backport into the main application can still be considered if a particular view or interaction is better served there. The choice between API consumption and any targeted backport remains open until the proposal is reviewed.

## 10. Proposed local development arrangement

**PROPOSAL — for review; no orchestration or database changes have been made**

The two repositories are separate Rails applications on different Rails generations:

- **Main GalaxyGame application:** Rails 7.x; proposed API provider and owner of authoritative game state.
- **Galaxy Game UI prototype:** Rails 8.x (the inspected baseline was Rails 8.1); proposed UI/client application.

If the API/client arrangement is adopted, both applications would normally run during integrated local development: the Rails 7 application serves the API, and the Rails 8 application serves the prototype UI. They remain separate processes and separate Git repositories.

A convenient developer experience could start the required processes with one command (for example, a shared Docker Compose or process-orchestration setup). This is only a local startup convenience; it does not merge the applications or their responsibilities. The exact command, ports, environment variables, health checks, and orchestration tool remain OPEN.

### PostgreSQL options

A single local PostgreSQL server/container could host more than one logical database. The important boundary is database ownership, not the number of Postgres containers:

- The main Rails 7 application connects to and owns its existing game database.
- The Rails 8 prototype must obtain game state through the main application's API; it must not read or write the main application's game tables directly.
- If the prototype needs persistence for UI-owned concerns (for example, its own user/session or saved UI preferences), it could use a separate logical database on the same PostgreSQL server.
- If the prototype does not need its own persistent records, it may not need a separate database at all.

Sharing one PostgreSQL server is a possible development setup, not a decision to share one game database or Active Record schema. Production topology may differ and remains out of scope for this proposal.

### Conceptual local process layout

```text
one developer startup command (proposal)
  ├─ PostgreSQL service
  │    ├─ main GalaxyGame database
  │    └─ optional prototype-owned database
  ├─ main GalaxyGame Rails 7 process (API provider)
  └─ Galaxy Game UI Rails 8 process (prototype/client)
             │
             └── HTTP requests to main app API
```

The API URL and credentials should be configured through environment variables rather than hardcoded. Whether browser requests go directly to the API or through a prototype-side proxy/backend remains an implementation question; configure CORS and authentication only after that request path is selected.

This proposal needs review against both repositories' actual Docker/Compose, database, and startup configuration before any setup changes are made.

## 11. Current prototype baseline

The initial repository inspection described:
- Rails 8.1;
- Propshaft;
- importmap-rails, Turbo and Stimulus;
- Tailwind CSS 4 through `tailwindcss-rails`;
- PostgreSQL/Active Record dependencies;
- no separate `package.json` or selected replacement frontend framework;
- no API namespace or prototype JSON reader at that snapshot;
- server-rendered dashboard ERB using placeholder data;
- no configured access to the main repository's JSON-data tree.

These are baseline observations from the inspected branch and date, not permanent claims. Re-check the live repository before implementation. The presence of Active Record/PostgreSQL does not prove that game-domain persistence has been migrated.

## 12. Related references

- [Project overview and architecture](README.md)
- [Interface and workflow direction](interface-and-workflows.md)
- [First-attempt reconciliation](first-attempt-reconciliation.md)
- [Screenshot evidence](assets/screenshots/galaxy-game-ui/README.md) — captured 2026-11-08
- Main-game lookup services: `galaxyGame/galaxy_game/app/services/lookup/`
- Main-game data path initializer: `galaxyGame/galaxy_game/config/initializers/game_data_paths.rb`
