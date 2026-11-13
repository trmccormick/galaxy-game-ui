# Screen Concepts and Low-Fidelity Wireframes

**Status:** Proposed screen/workspace concepts — for owner review  
**Last updated:** 2026-11-08

This page translates the application direction into candidate screens and workspace layouts. These are information-architecture sketches, not approved visual designs, final navigation, or implementation tasks. The text wireframes make hierarchy, context, actions, and information needs reviewable before detailed visual design.

## 1. Screen-design rules

Every screen proposal should answer:

1. Who is using it: player, administrator, or both with different permissions?
2. What are they trying to do: inspect, compare, plan, configure, transact, or operate?
3. What is the active context: current physical location, selected object, selected organization/settlement, or broader query scope?
4. What information is authoritative: game JSON data, migrated model/service, persisted player state, or derived presentation data?
5. How fresh is it: static reference data, recently fetched state, live/periodic updates, or historical snapshot?
6. What can the user do: read-only inspection or an action requiring authorization and backend validation?
7. What happens when data is missing or stale: loading, empty, unavailable, stale, and error states must be designed rather than hidden.

The interface should make context visible without forcing the player through a deep hierarchy. A selected celestial body is a context, not necessarily a primary-navigation level.

## 2. Candidate player application shell

### Concept A — Player home / operational overview

**Purpose:** Give the player a useful starting point and quick access to important work without committing to a fixed six-panel dashboard.

```text
┌──────────────────────────────────────────────────────────────────────┐
│ GALAXY GAME     Home  Map  Assets  Industry  Economy  Research  ...  │
│                                                     Account / Status │
├──────────────────────────────────────────────────────────────────────┤
│ CURRENT LOCATION: [Earth / Sol ▼]    SELECTED: [Earth ▼]  [Change]   │
├──────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  OPERATIONAL OVERVIEW                         [Customize? OPEN]      │
│  ┌──────────────────────────────┐  ┌──────────────────────────────┐  │
│  │ Current situation            │  │ Active work / notifications   │  │
│  │ Location, status, key facts   │  │ Items needing attention      │  │
│  └──────────────────────────────┘  └──────────────────────────────┘  │
│                                                                      │
│  RECENT / IMPORTANT                                                 │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │ Recent activity, saved views, or relevant next actions          │ │
│  └────────────────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────────────────┘
```

**Direction:** The home screen should orient the player and expose useful entry points. It should not become a mandatory container for every subsystem. Panel count, customization, and exact metrics are OPEN.

### Concept B — Contextual selector pattern

Use selectors and breadcrumbs inside relevant workspaces rather than mirroring the game hierarchy in the global sidebar.

```text
MAP / SYSTEM VIEW
[Galaxy ▼]  →  [Star System ▼]  →  [Celestial Body ▼]
                                      |
                                      +-- selected object details
                                      +-- inspect / open workspace
```

A selection must make clear whether it changes the player's actual location or merely changes the object being inspected. Selecting a distant object must not imply travel.

## 3. Candidate system map workspace

**Purpose:** Navigate and inspect spatial relationships at the scale supported by the game.

```text
┌──────────────────────────────────────────────────────────────────────┐
│ MAP   [Galaxy ▼] [System ▼]                         [Filters] [Find] │
├──────────────────────────────────────────────────────────────────────┤
│ OBJECTS / FILTERS        │                 MAP CANVAS                 │
│                          │                                            │
│ Stars                    │           * Star                           │
│ Planets                  │                 o Planet                    │
│ Moons                    │                      · Moon                 │
│ Stations                 │                                            │
│ Ships / assets           │       [pan] [zoom] [fit] [layers]           │
│                          │                                            │
├──────────────────────────┴────────────────────────────────────────────┤
│ SELECTED OBJECT: Name / type / key facts / available actions          │
└──────────────────────────────────────────────────────────────────────┘
```

Candidate interactions: pan/zoom, select marker, filter object types, search, inspect details, and open the selected object's workspace. Route visualization is a later capability if the game provides meaningful route data.

The map's selected object and the player's current physical location are separate state.

## 4. Candidate celestial-body inspection workspace

**Purpose:** Preserve and improve the main game's Monitor → Planetary → Surface inspection concepts.

```text
┌──────────────────────────────────────────────────────────────────────┐
│ SOL / [Earth ▼]                         [Current location indicator] │
├──────────────────────────────────────────────────────────────────────┤
│ [MONITOR] [PLANETARY] [SURFACE] [OTHER TABS AS JUSTIFIED]             │
├──────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  LEFT / PRIMARY VISUALIZATION             RIGHT / INSPECTION          │
│  ┌──────────────────────────────┐         ┌────────────────────────┐ │
│  │ Planet / map / surface view  │         │ Selected layer/object  │ │
│  │                              │         │ Summary and attributes │ │
│  │ Layer controls               │         │ Data source / updated  │ │
│  └──────────────────────────────┘         │ Available actions      │ │
│                                           └────────────────────────┘ │
└──────────────────────────────────────────────────────────────────────┘
```

**Monitor** should communicate planetary-scale condition and broad environmental information. **Planetary** should expose relevant planet-level systems and data. **Surface** should support geographic inspection and, where implemented, local terrain/biome/occupant context.

This is a preservation target for existing game capabilities, not a declaration that every layer or visualization is implemented in the prototype. Exact layer contents and actions must be reconciled against current main-game code and domain documentation.

## 5. Candidate assets / inventory workspace

**Purpose:** Search and inspect assets and their locations without assuming a particular storage hierarchy.

```text
┌──────────────────────────────────────────────────────────────────────┐
│ ASSETS / INVENTORY                      [Scope: All accessible ▼]   │
├──────────────────────────────────────────────────────────────────────┤
│ Search [____________________]  Type [All ▼]  Location [Any ▼]        │
│                                                                      │
│ SUMMARY: [category/count metrics only when backed by real data]      │
├──────────────────────────────────────────────────────────────────────┤
│ Item / Asset       Type       Quantity   Location       Status       │
│ -------------------------------------------------------------------- │
│ ...                                                                  │
├──────────────────────────────────────────────────────────────────────┤
│ Selected item details / provenance / permitted actions              │
└──────────────────────────────────────────────────────────────────────┘
```

Candidate interactions: filtering, sorting, typeahead, multi-select, bulk selection, detail inspection, and location/context filtering. Permissions and action availability must come from backend-authoritative state.

## 6. Candidate market / economy workspace

**Purpose:** Support discovery and comparison of market information, with clear separation between reference prices, offers, orders, and completed transactions where those concepts exist.

```text
┌──────────────────────────────────────────────────────────────────────┐
│ MARKET                                  [Market scope / location ▼]  │
├──────────────────────────────────────────────────────────────────────┤
│ Search [____________________]  Category [All ▼]  Sort [Relevant ▼]  │
│                                                                      │
│ ┌──────────────────────────────────────────────────────────────────┐ │
│ │ Market summary / selected item context                            │ │
│ └──────────────────────────────────────────────────────────────────┘ │
│                                                                      │
│ Item             Available / offer data       Price      Details     │
│ -------------------------------------------------------------------- │
│ ...                                                                  │
│                                                                      │
│ Selected item: offers / history / permitted transaction actions     │
└──────────────────────────────────────────────────────────────────────┘
```

Do not invent market depth, price history, or trading actions before corresponding backend behavior exists. Financial actions require backend validation, authorization, and transaction handling.

## 7. Candidate research / industry workspace

**Purpose:** Present research, blueprints, manufacturing, and related progress according to actual player workflows and domain scope.

Possible regions:
- discovery/search and category filters;
- selected technology, blueprint, or project details;
- prerequisites and dependencies;
- current progress and status;
- available actions, costs, and output details only when supported by authoritative data.

A fixed wireframe is intentionally deferred. The main game's current research/industry behavior and the player's ownership/context model must be inspected before deciding whether these belong together or in separate workspaces.

## 8. Candidate settlement / logistics workspace

**Purpose:** Help players inspect a settlement or operational site, its infrastructure, inventory flows, and active work.

Potential regions:
- selected site/settlement identity and location;
- infrastructure and service status;
- inbound/outbound resources and hauling;
- active jobs or operations;
- AI Manager status and available player directives;
- permissions and communication constraints.

This is a workflow candidate, not approval for a settlement-only global menu or a claim that all economy/research/missions are settlement-scoped. Main-game domain rules and services determine the actual boundaries.

### Settlement visual direction — early exploration

**NOT FINALIZED — visual/gameplay exploration only**

A simplified SimCity-like settlement presentation is a useful starting point. Surviving Mars is a particularly relevant visual reference for habitats, life support, population, and infrastructure; Anno 1800 and Frostpunk may offer useful presentation patterns for economic summaries and high-level settlement conditions. These are references, not mechanics to copy.

The view may eventually need to distinguish NPC settlement infrastructure from player- or corporation-owned units operating alongside it. Early discussion explored the possibility that an outside player/corporation could lease a connection and build its own warehouse, habitat, industrial unit, or other structure, provided the settlement's base can connect it and supply the services it needs—or can expand to do so. Independent player-owned utility generation (for example, solar or fusion power) and supplying surplus power were also brainstormed as possibilities.

**None of these leasing, construction, service, expansion, or utility-market details are finalized gameplay.** Pricing, approval, capacity, ownership boundaries, infrastructure responsibilities, and available interactions remain undecided. The prototype may explore a visual way to communicate these relationships, but must not present speculative mechanics as implemented or approved.

The design should avoid assuming that players directly manage every NPC building, worker, or resident. The appropriate level of player influence is still open.

## 9. Admin Dashboard workspace

**Purpose:** Operate and administer the GalaxyGame web application and simulation. This is not a second Player Dashboard and must not reuse player-facing views as its primary information architecture.

The Admin Dashboard is expected to provide an overview and access to focused workspaces. Candidate areas include:

- **AI Manager:** mission/operations supervision, decisions, wormhole network, EM economy, Hammer Protocol scouting/harvesting, and expansion strategy.
- **Map Studio:** known-world reconstruction, extrasolar map generation, and planetary Digital Twin data workflows.
- **StarSim Generator:** procedural solar-system generation controls, configuration, run inspection, and generated-system review.
- **TerraSim:** planetary/environmental simulation controls and status.
- **Spawning System:** planned administration of small-body populations (asteroids, comets, Kuiper Belt objects, Oort Cloud objects), distributions, composition rules, and spawn behavior. This subsystem is not yet built.
- **Solar System Management:** export/unload systems to JSON, import/validate prepared systems, manage a prepared-system catalog, and select whether system creation uses a prepared system or StarSim generation.
- **Blueprint Management:** definitions for units, assets, structures, craft, equipment, and components.
- **Material Management:** material JSON definitions and their physical, chemical, and resource properties.
- **Configuration & Operational Data:** UI tools for tuning JSON configuration without requiring manual file edits; specialized editors where useful and schema-aware JSON editing where appropriate.
- **Template & Version Management:** expose existing template-version-control files and behavior, including compatibility, validation, comparison, and migration status after auditing what is already implemented.
- **User & Account Management:** account lookup, status/activity review, password-reset workflows, account suspension/restoration, roles, permissions, and administrative audit history.
- **System administration:** application health, background jobs, data integrity, logs, backup/recovery, and administrative permissions.

This is a capability inventory, not a finalized navigation tree or one-screen-per-item commitment. We will decide what each screen needs individually. Backend services remain authoritative for simulation, authorization, validation, persistence, and state-changing actions. The UI must never expose or retrieve user passwords.

## 10. AI Manager workspace concept

AI Manager is a major dedicated workspace inside the Admin Dashboard. It needs more than a mission list or activity feed.

Its candidate areas include:
- mission objectives, planning, asset deployment, logistics, and execution oversight;
- wormhole network state, relative stability, mass throughput, mass capacity, EM ejection, harvesting, captured reserves, and stabilization;
- system discovery and survey through natural wormholes;
- Hammer Protocol decisions: continue harvesting, stabilize, build an AWS connection, plan settlement, or force a natural exit to shift and scout another system;
- expansion forecasts that balance EM availability, system value, AWS investment, settlement costs, ship travel time, and resupply;
- decision records, operator review, intervention, and training evidence.

A discovered system has a harvestable EM field under the current design; unvisited local-bubble systems remain unknown until discovered and surveyed. Discovery does not automatically require an AWS pair. A settlement candidate will likely be connected to Sol by an AWS pair while its natural wormhole remains open, allowing initial settlement logistics through a stabilized natural or artificial connection.

Sol's natural wormhole remains present for the current human-expansion scenario, although it is comparatively—not absolutely—more stable due to its placement opposite Jupiter. The Eden-side snap predates EM stabilization technology. The game-domain wiki is authoritative for these mechanics.

## 11. Shared interaction and state requirements

Across workspaces, plan for:
- explicit loading, empty, error, stale, and permission-denied states;
- keyboard-operable controls and visible focus;
- responsive behavior that preserves task-critical information;
- consistent search, filter, sort, and selection behavior;
- clear distinction between selected object, active context, and current location;
- confirmation and result feedback for state-changing actions;
- backend-authoritative validation and permission checks;
- data freshness/source labels where the user could otherwise misinterpret age or authority.

## 12. Screen inventory and design priority

| Workspace | User value | Planning priority | State |
|---|---|---|---|
| Player home / overview | Orientation and entry points | High | Proposed |
| Contextual selectors | Navigation and scope clarity | High | Proposed shared pattern |
| System map | Spatial navigation and inspection | High candidate | Proposed |
| Celestial-body inspection | Preserve Monitor/Planetary/Surface concepts | High candidate | Proposed |
| Assets / inventory | Search and inspect player assets | Candidate | Proposed |
| Market / economy | Discover and compare economic data | Candidate | Proposed |
| Research / industry | Understand progress and prerequisites | Candidate | OPEN boundaries |
| Settlement / logistics | Inspect infrastructure and flows | Candidate | OPEN boundaries |
| Admin Console | Application administration | Separate track | Proposed |

Priority is a planning aid, not a commitment to implement in this order. The first workflow must be selected after the current prototype baseline and user priorities are reviewed.

## 13. Decisions still open

- Whether player home is configurable, curated, or primarily a launch/overview page.
- Exact global navigation destinations and labels.
- Whether map and celestial-body inspection are one workspace or separate linked workspaces.
- Which existing Monitor/Planetary/Surface details are required in the first iteration.
- Which assets, market, research, industry, settlement, and logistics workflows are implemented in the first application stages.
- Whether screens need real-time/push updates versus request/refresh behavior.
- Exact responsive breakpoints and mobile-specific interaction patterns.
- Admin Console scope and relationship to existing admin routes.

## 14. Relationship to implementation tasks

Future tasks should link to the relevant screen section and state which parts of the concept are in scope. A task must identify current source files and verified data/API dependencies; this page alone does not authorize implementation.

A task should not silently turn a proposed wireframe into a final design. If implementation requires a decision not recorded here, return to the wiki for review before proceeding.
