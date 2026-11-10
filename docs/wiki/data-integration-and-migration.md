# Data Integration and Backend Migration Direction

**Status:** Working architecture direction — for owner review  
**Last updated:** 2026-11-08  
**Scope:** JSON data access, Rails API responsibilities, JavaScript integration and progressive migration from the main game.

## 1. Target responsibility split

The prototype is becoming the foundation of the new Galaxy Game interface, rather than remaining an appearance-only mockup.

### JavaScript interface

JavaScript is the primary presentation and interaction layer. It is expected to handle navigation, contextual selection, dashboards, maps, tables, charts, filtering, sorting, search, transient UI state and incremental display updates.

The frontend may maintain transient presentation state. It must not become the authority for game rules, validation or durable game state.

### Rails application backend

Rails provides the application/API boundary and authoritative backend behavior, including:
- authentication and authorization;
- application-level API endpoints and response contracts;
- controlled access to game data;
- application and domain services;
- validation and enforcement of game rules;
- persistence and transactions;
- calculations and future simulation/operations integration.

The API should expose resources and contracts designed for application workflows. It should not merely return arbitrary source JSON files as an unstructured pass-through.

## 2. Initial data path

The initial integration path is:

```text
Galaxy Game JSON data
        ↓
Prototype JSON reader
        ↓
Rails API
        ↓
JavaScript interface
```

There is no existing JSON reader in the prototype branch inspected for the initial wiki. A reader must be built in this repository. The starting point is to inspect and port/adapt the main game's lookup-service behavior, not to assume a reader already exists.

This is a first integration path, not a permanent restriction that all game data must always come from JSON. As models and services are migrated, the API may use those authoritative application sources behind stable contracts where practical.

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

## 7. Application boundary remains OPEN

The long-term boundary is not decided:

- the prototype may ultimately become the complete Galaxy Game application; or
- it may remain the frontend/API application while some game logic continues in the main game.

Do not design a large distributed architecture or duplicate services based on an assumed answer. Prefer a small boundary that can evolve as migration decisions become clearer.

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
