# Data Integration and Backend Migration Direction

**Status:** Established integration direction with endpoint details open  
**Last updated:** 2026-11-11  
**Scope:** JSON data access, Rails API responsibilities, JavaScript integration and progressive migration from the main game.

## 1. Target responsibility split

The intended architecture is a **separate UI prototype consuming an API exposed by the main GalaxyGame application**. The prototype establishes the presentation and interaction model; the main application remains the authoritative game backend. The prototype should not independently recreate game rules or become a second source of simulation truth.

### Prototype UI client

The prototype is the presentation and interaction layer. It handles navigation, contextual selection, dashboards, maps, tables, charts, filtering, sorting, search, transient UI state and incremental display updates.

It requests game data and permitted operations from the main application's API. It may use clearly labeled mock data while a screen is being designed, but mocks are not live state or API contracts.

### Main GalaxyGame application and API

The main application exposes the game capabilities required by the UI through deliberate, documented API endpoints and response contracts. It remains responsible for:
- authentication and authorization;
- authoritative game state and controlled data access;
- application and domain services;
- validation and enforcement of game rules;
- persistence and transactions;
- calculations and simulation/operations behavior;
- authorization and execution of state-changing operations.

The API should expose resources and workflows designed for the UI, reusing existing main-app services and data access. It should not merely return arbitrary source JSON files as an unstructured pass-through.

The API surface must be inspected and built incrementally; this document does not claim that the required endpoints already exist.

## 2. Intended data path

```text
Main GalaxyGame application
  ├─ authoritative models, services, calculations and game data
  └─ application API (documented resources and operations)
                 ↓
       Separate prototype UI client
                 ↓
       JavaScript presentation and interaction
```

The main application is the source of truth. Its API should call or adapt existing application services and lookup behavior as appropriate, then return stable response contracts for the prototype. The prototype should consume those contracts rather than independently reading the main application's private data tree or copying its domain logic.

For early visual development, the prototype may temporarily use mock fixtures or local JSON. Keep that path explicitly separate from the live API client so that switching to real data does not require rewriting the screen and so mock assumptions do not silently become backend requirements.

This replaces the earlier prototype-owned JSON-reader-first integration sketch as the target architecture. Existing lookup services remain important because they may supply the main application's API implementation; they are not a reason to duplicate a reader in the prototype.

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

The first API/JavaScript integration should prove one complete path:

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

The current direction is that the main GalaxyGame application exposes the API and the prototype consumes it. This is the preferred integration model, not an undecided choice between two equal architectures.

The exact API namespace, endpoint inventory, authentication flow, response schemas, versioning strategy, and deployment topology remain OPEN. Start with a small API surface shaped by reviewed UI workflows. Keep domain logic and authoritative state in the main application.

A targeted backport into the main application can still be considered if a particular view or interaction is better served there, but it does not change the default direction: the prototype is intended to consume main-app capabilities through the main-app API.

## 8. Current prototype baseline

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

## 9. Related references

- [Project overview and architecture](README.md)
- [Interface and workflow direction](interface-and-workflows.md)
- [First-attempt reconciliation](first-attempt-reconciliation.md)
- [Screenshot evidence](assets/screenshots/galaxy-game-ui/README.md) — captured 2026-11-08
- Main-game lookup services: `galaxyGame/galaxy_game/app/services/lookup/`
- Main-game data path initializer: `galaxyGame/galaxy_game/config/initializers/game_data_paths.rb`
