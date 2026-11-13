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

## 2. Proposed data path

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

## 3. Main-game lookup services: candidate starting point

The main repository has lookup services under:

`galaxy_game/app/services/lookup/`

The inspected code includes `BaseLookupService`, `BlueprintLookupService` and `UnitLookupService`, among other lookup services. The layer reads JSON, provides lookup/search behavior and uses class-level caching in several services.

The main application also defines `GalaxyGame::Paths` in `config/initializers/game_data_paths.rb`. The initial inspection identified a path-handling difference that must be understood before porting:
- `GalaxyGame::Paths` supports `GALAXY_JSON_DATA_PATH` and a fallback;
- `BaseLookupService` initializes an instance data path from `Rails.root/app/data`;
- subclasses also use path constants for their specific data locations.

A reasonable first code slice to investigate is path configuration, `BaseLookupService`, `BlueprintLookupService` and `UnitLookupService`. This is a recommendation, not an approved task sequence. Read the complete implementations and specs before deciding the exact slice.

## 4. Reader design questions

Resolve these through code inspection and a small tested implementation, not by assumption:

1. **Ownership:** copy/adapt the lookup code into this app, or establish a shared library/package? No choice is final.
2. **Data location:** how will the prototype receive the main repository's `data/json-data` tree (configured path, mounted directory, or another supported arrangement)?
3. **Path precedence:** reconcile `GALAXY_JSON_DATA_PATH`, `GalaxyGame::Paths` and the base service's Rails-root behavior.
4. **Cache semantics:** preserve process-lifetime class caches, add explicit refresh/invalidation, or use another lifecycle? Do not change semantics accidentally.
5. **Error behavior:** preserve useful missing-file, malformed-data and lookup error behavior while making API failure responses deliberate.
6. **First useful data:** which reader/service is required for the first actual screen and endpoint? Do not port every lookup service up front.

## 5. First vertical slice

If the proposal is adopted, the first API/JavaScript integration should prove one complete path:

1. Read a real, relevant game-data source through the prototype reader.
2. Expose it through one Rails endpoint with a deliberate application-level response contract.
3. Request it from JavaScript.
4. Render it dynamically in an existing prototype view.
5. Verify success, empty and error behavior, authentication/authorization as applicable, and tests.

The candidate first data domain is not locked. Basic models and lookup data are sensible foundations, and Galaxy → SolarSystem → CelestialBody is one possible sequence, but the first slice should be chosen from the current UI workflow and inspected source data.

Do not start this slice until the current UI work is committed or explicitly paused and reviewed. Do not overlap a substantial Qwen UI implementation with a new integration track.

## 6. Progressive migration

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

## 7. Application/API boundary

The proposal is that the main GalaxyGame application exposes the API and the prototype consumes it. This has not yet been adopted as the implementation architecture.

The exact API namespace, endpoint inventory, authentication flow, response schemas, versioning strategy, and deployment topology remain OPEN. Start with a small API surface shaped by reviewed UI workflows. Keep domain logic and authoritative state in the main application.

A targeted backport into the main application can still be considered if a particular view or interaction is better served there. The choice between API consumption and any targeted backport remains open until the proposal is reviewed.

## 8. Proposed local development arrangement

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

## 9. Current prototype baseline

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

## 10. Related references

- [Project overview and architecture](README.md)
- [Interface and workflow direction](interface-and-workflows.md)
- [First-attempt reconciliation](first-attempt-reconciliation.md)
- [Screenshot evidence](assets/screenshots/galaxy-game-ui/README.md) — captured 2026-11-08
- Main-game lookup services: `galaxyGame/galaxy_game/app/services/lookup/`
- Main-game data path initializer: `galaxyGame/galaxy_game/config/initializers/game_data_paths.rb`
