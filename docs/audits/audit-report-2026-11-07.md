# Galaxy Game UI — Main Game and Documentation Discovery Audit Report

**Date**: 2026-11-07
**Scope**: Read-only investigation of `galaxyGame` (main game) and `galaxy-game-ui` (UI prototype)
**Agent**: Qwen
**Status**: REPORT — awaiting review

---

## A. Verified Game Structure

### Domain Hierarchy (from schema + models)

```
Galaxy (table: galaxies)
  └── has_many :solar_systems
        └── SolarSystem (table: solar_systems)
              ├── has_one :current_star → Stars
              ├── has_many :stars → CelestialBodies::Star
              ├── has_many :terrestrial_planets → CelestialBodies::Planets::Rocky::TerrestrialPlanet
              ├── has_many :gas_giants → CelestialBodies::Planets::Gaseous::GasGiant
              ├── has_many :ice_giants → CelestialBodies::Planets::Gaseous::IceGiant
              ├── has_many :moons → CelestialBodies::Satellites::Moon
              ├── has_many :dwarf_planets → CelestialBodies::MinorBodies::DwarfPlanet
              └── has_many :celestial_bodies (general)
                    └── CelestialBodies::CelestialBody (base class)
                          ├── belongs_to :solar_system (optional)
                          ├── has_one :atmosphere → CelestialBodies::Spheres::Atmosphere
                          ├── has_one :biosphere → CelestialBodies::Spheres::Biosphere
                          ├── has_one :geosphere → CelestialBodies::Spheres::Geosphere
                          ├── has_one :hydrosphere → CelestialBodies::Spheres::Hydrosphere
                          ├── has_many :colonies
                          ├── has_many :materials
                          ├── has_many :orbiting_craft → Craft::BaseCraft
                          ├── has_many :star_distances → StarDistance
                          └── has_many :locations → Location::CelestialLocation

        └── Wormhole (table: wormholes) — connects two solar_system_a/b
        └── DwarfPlanet (table: dwarf_planets) — direct child of SolarSystem

Colony (table: colonies)
  ├── belongs_to :celestial_body
  ├── has_many :settlements → Settlement::BaseSettlement
  ├── has_one :account → Financial::Account
  ├── has_one :inventory
  └── validates :must_have_multiple_settlements (≥2 settlements required)

Settlement::BaseSettlement (table: base_settlements)
  ├── belongs_to :colony
  ├── belongs_to :player (owner)
  ├── has_one :marketplace → Market::Marketplace
  ├── has_one :location → Location::CelestialLocation
  ├── has_many :base_units → Units::BaseUnit
  ├── has_many :jobs, :construction_jobs
  ├── has_many :docked_crafts → Craft::BaseCraft
  ├── has_many :orbital_construction_projects
  └── enum settlement_type: { base: 0, outpost: 1, settlement: 2, city: 3, station: 4 }

Player (table: players)
  ├── has_many :colonies
  ├── has_many :blueprints
  ├── has_one :inventory (via polymorphic)
  └── string :active_location

Account (table: accounts) — polymorphic via :accountable_type/id
  ├── decimal :balance (precision 20, scale 8)
  └── belongs_to :currency

Mission (table: missions)
  ├── belongs_to :settlement
  ├── enum :status
  └── string :mission_type

SpecialMission (table: special_missions)
  └── belongs_to :settlement

Blueprint (table: blueprints)
  └── belongs_to :player

Trade (table: market_trades)
  ├── buyer/seller (polymorphic)
  ├── buyer/seller_settlement_id
  └── resource, quantity, price

LogisticsContract (table: logistics_contracts)
  ├── from/to settlement
  ├── provider → LogisticsProvider
  └── emergency flag, failure_reason

MegaProject (table: mega_projects)
  └── belongs_to :settlement
```

### Key Model Relationships — Verified Facts

1. **Galaxy → SolarSystem**: `Galaxy` has_many `solar_systems`. `SolarSystem` belongs_to `galaxy` (optional). The `galaxies` table stores `name`, `identifier`, `mass`, `diameter`, `galaxy_type` (spiral/elliptical/irregular/ring/lenticular), `star_count`, `age_in_billions`. **(VERIFIED: galaxy.rb lines 1-47)**

2. **SolarSystem → CelestialBodies**: A solar system contains stars, terrestrial planets, gas giants, ice giants, moons, and dwarf planets — all as subclasses of `CelestialBody`. The base `CelestialBody` table stores physical properties (size, gravity, density, mass, radius, orbital_period, surface_temperature, albedo, insolation, crust/mantle/core JSON). **(VERIFIED: celestial_body.rb, schema)**

3. **Colony → Settlement**: A colony must have ≥2 settlements (validation enforced). Settlements are the player-facing operational unit. Settlement types: base, outpost, settlement, city, station. **(VERIFIED: colony.rb lines 1-40; base_settlement.rb)**

4. **Player → Colony**: Players own colonies. Each colony has its own account (balance) and inventory. **(VERIFIED: player.rb, colony.rb)**

5. **Settlement → Marketplace**: Each settlement can have one marketplace with NPC pricing (`Market::NpcPriceCalculator`). Settlements also have surface storage, base units (habitat modules), and manufacturing jobs. **(VERIFIED: base_settlement.rb)**

6. **Wormhole**: Connects two solar systems (`solar_system_a_id`, `solar_system_b_id`). Has stability, decay_rate, mass_limit, exotic_resources flags, natural/artificial distinction. **(VERIFIED: schema wormholes table)**

7. **Economy**: Dual economy — GCC (player) and Virtual Ledger (NPC). Exchange rates between currencies. Market trades track buyer/seller settlements. Logistics contracts handle inter-settlement transport. **(VERIFIED: accounts, market_trades, logistics_contracts, exchange_rates tables)**

8. **Terraforming**: TerraformingProject model exists. TerraSim service handles planetary modification simulation. Biology system (biospheres, life forms, biomes) models ecological changes. **(VERIFIED: terraforming_project.rb, terra_sim/ services, biology/ models)**

### Data Files — Star System Blueprints

Located at `data/json-data/star_systems/`:
- **48+ star system JSON files** including Sol, Alpha Centauri, Tau Ceti, Sirius, Procyon, Ross 128, and many others
- Each file defines a procedurally generated star system with celestial bodies
- `sol-complete.json` and `sol.json` are the primary Sol system definitions
- Additional systems: `61_cygni.json`, `epsilon_eridani.json`, `gliese_876.json`, `wolf_1061.json`, etc.

---

## B. Implemented Functionality

### Complete & Functional (verified by code structure)

| Feature | Status | Evidence |
|---------|--------|----------|
| **Multi-galaxy support** | IMPLEMENTED | `galaxies` table with unique identifier; `Galaxy` model with type enum, mass/diameter properties |
| **Procedural star system generation** | IMPLEMENTED | `StarSim::SystemBuilderService`; 48+ JSON system blueprints in `data/json-data/star_systems/` |
| **Celestial body physics** | IMPLEMENTED | Full physical properties (gravity, density, mass, radius, orbital mechanics) in `CelestialBody` model |
| **Atmospheric/hydrosphere/geosphere/biosphere simulation** | IMPLEMENTED | Four sphere models with JSON composition data; TerraSim service for planetary modification |
| **Colony management** | IMPLEMENTED | Colony model with settlements, accounts, inventory; validates ≥2 settlements |
| **Settlement types** | IMPLEMENTED | base/outpost/settlement/city/station enum; life support, energy management, manufacturing |
| **NPC market pricing** | IMPLEMENTED | `Market::NpcPriceCalculator` with bid/ask spreads per resource per settlement |
| **Player contracts (player-first)** | IMPLEMENTED | `MissionContract`, `SpecialMission`, `PlayerContract` models; 24-48h timeout pattern |
| **Logistics network** | IMPLEMENTED | `LogisticsContract`, `LogisticsManifest`, `LogisticsProvider`; cycler integration |
| **Dual economy (GCC + Virtual Ledger)** | IMPLEMENTED | `Account` model with balance; `ExchangeRate`; `LedgerEntry` for NPC accounting |
| **Trade system** | IMPLEMENTED | `MarketTrade` model tracking buyer/seller settlements, resources, prices |
| **Blueprints/manufacturing** | IMPLEMENTED | `Blueprint` model with input/output resources, production time, GCC cost; `ManufacturingService` |
| **Construction jobs** | IMPLEMENTED | `ConstructionJob` model with status, progress, blueprint association |
| **Mega projects** | IMPLEMENTED | `MegaProject` model with budget, material requirements, deadlines |
| **Wormhole network** | PARTIALLY IMPLEMENTED | Schema complete (stability, decay, mass limits); `WormholeNavigator`, `WormholeExpansionService` exist |
| **AI Manager** | IMPLEMENTED | `AiManager` service; `AiDecision`/`AiDecisionLog`; pattern learning; mission planning |
| **Cycler system** | PARTIALLY IMPLEMENTED | `Cycler` model with encounter schedules; `CyclerSystemArchitecture` docs exist |
| **Terraforming** | PARTIALLY IMPLEMENTED | `TerraformingProject` model; TerraSim service; Venus-Mars corridor design documented |
| **Biology/life simulation** | PARTIALLY IMPLEMENTED | `BiologyLifeForm`, `Biosphere`, `Biome` models; alien life forms on celestial bodies |
| **Orbital mechanics** | IMPLEMENTED | `OrbitalMechanics` concern; `OrbitalRelationships` table with full Keplerian elements |
| **Resource deposits** | IMPLEMENTED | `ResourceDeposit` model with depletion curves, extraction difficulty |
| **Adapted features** | IMPLEMENTED | `AdaptedFeature` for lava tubes, craters, strategic sites on celestial bodies |
| **Surface storage** | IMPLEMENTED | `SurfaceStorage` model; material piles per settlement |
| **Inventory system** | IMPLEMENTED | Polymorphic `Inventory` with `Item` entries; capacity tracking |
| **Financial transactions** | IMPLEMENTED | `Transaction`, `LedgerEntry`, `Bond`, `BondRepayment` models |
| **Insurance** | PARTIALLY IMPLEMENTED | `InsurancePolicy` model exists; `ClaimsClaimPayouts`/`ClaimsClaimDenials` tables |
| **Consortium/voting** | PARTIALLY IMPLEMENTED | `ConsortiumMembership`, `RouteProposal`, `RouteProposalVote` models |
| **Player progression** | ESTABLISHED INTENT | Beginner/Intermediate/Advanced phases documented in `docs/gameplay/mechanics.md` |

### Represented in Models but Not Yet Operational (player-facing)

| Feature | Evidence | Notes |
|---------|----------|-------|
| **Galaxy browsing UI** | `GalaxiesController` exists in admin namespace; `galaxies` routes exist under `/admin/galaxies` | No player-facing galaxy index/listing controller |
| **Star system explorer** | `SolarSystemsController#index`/`#show` exists (public); `GameController#index` loads Sol | Limited — no multi-galaxy navigation |
| **Celestial body detail** | `CelestialBodiesController#show` with map/geological_features endpoints | Functional but minimal player-facing presentation |
| **Settlement management** | Settlements exist in admin routes; `settlements#index` under `/admin/settlements` | No dedicated player settlement dashboard |
| **Economy/market dashboard** | Market models complete; `Market::NpcPriceCalculator` works | No player-facing market UI yet |
| **Research tree** | Blueprint research levels exist (`current_research_level`) | No research progression UI |
| **Missions dashboard** | Mission/contract models complete | No player mission board UI |
| **Multi-galaxy navigation** | Galaxy model exists with 48+ star systems generated | Player cannot currently navigate between galaxies |

### Established Design Intent (documented, not implemented)

| Feature | Source | Status |
|---------|--------|--------|
| **Eden snap event / disconnect narrative** | `docs/wiki/player/eden_disconnect_and_emergent_history.md` | Story framework; no implementation |
| **AWS (Arbitrary Wormhole Station) inter-system network** | `docs/wiki/technical/portals_and_aws.md` | Design intent only |
| **Venus industrial hub → Mars terraforming corridor** | `docs/gameplay/terraforming.md`, `docs/architecture/ai_manager/AI_MANAGER_INTENT.md` | Extensively documented; no player-facing implementation |
| **Player entry at AWS technology online** | `docs/wiki/player/first_hour_and_entry_state.md` | Design intent; not implemented |
| **Portal technology (low-mass, paired)** | `docs/wiki/technical/portals_and_aws.md` | Design intent only |
| **Interstellar communications with light-speed delay** | `docs/wiki/engineering/interstellar_communications.md` | Design intent only |
| **Settlement progression tiers** | `docs/wiki/player/settlement_progression_and_footholds.md` | Draft wiki page; no code enforcement |
| **Player roles and alignment** | `docs/wiki/player/player_roles_and_alignment.md` | Intent only; verify against code |
| **Easter eggs** | `docs/gameplay/easter_eggs.md` | Concept documented |

---

## C. Documentation Inventory

### Primary Documentation Sources

| Source | Location | What It Establishes |
|--------|----------|-------------------|
| **Wiki Home** | `galaxyGame/docs/wiki/README.md` | Live front door; navigation by category (astronomy, logistics, player, infrastructure, engineering, technical, UI) |
| **Status & Gaps** | `galaxyGame/docs/wiki/status-and-gaps.md` | Documentation posture; known gaps; what's verified vs. intent |
| **Core Mechanics** | `galaxyGame/docs/gameplay/mechanics.md` | Game overview, player-first system, core loop, terraforming, economy, progression |
| **Player Experience Boundaries** | `galaxyGame/docs/gameplay/player_experience_boundaries.md` | Economic transparency, fair competition rules, game balance constraints |
| **Terraforming Design** | `galaxyGame/docs/gameplay/terraforming.md` | Venus-Mars corridor, AI Manager terraforming options, player participation model |
| **AI Manager Intent** | `galaxyGame/docs/architecture/ai_manager/AI_MANAGER_INTENT.md` | Virtual ledger, cycler economics, manifest generation, player-first priority |
| **AI Manager Role** | `galaxyGame/docs/architecture/ai_manager/AI_MANAGER_ROLE.md` | AI Manager's market role (infrastructure only, never competes with players) |
| **Architecture Overview** | `galaxyGame/docs/architecture/overview.md` | System architecture; planetary systems, space infrastructure, economic engine |
| **Pre-Player Era Pipeline** | `galaxyGame/docs/wiki/infrastructure/pre_player_era_logistics_pipeline.md` | Sol Core → L1 Shipyards → Mars Moon → Belt Expansion expansion tree |
| **System Blueprints** | `galaxyGame/docs/wiki/astronomy/system_blueprints.md` | StarSim procedural generation; JSON system loading |
| **First Hour & Entry State** | `galaxyGame/docs/wiki/player/first_hour_and_entry_state.md` | Player entry at AWS; active starts; economy at entry |
| **Eden Disconnect** | `galaxyGame/docs/wiki/player/eden_disconnect_and_emergent_history.md` | Snap event, emergent states, recovery protocols |
| **Settlement Progression** | `galaxyGame/docs/wiki/player/settlement_progression_and_footholds.md` | Tiered evolution from early foothold |
| **Portals & AWS** | `galaxyGame/docs/wiki/technical/portals_and_aws.md` | Portal rules, AWS inter-system networking |
| **Natural Wormholes** | `docs/wiki/technical/natural_wormholes_and_em.md` | Wormhole physics, mass limits, EM harvest/reset |
| **UI Branding & Entry** | `galaxyGame/docs/wiki/ui/01_branding_and_entry_experience.md` | Shared visual identity; entry sequence; design intent ownership |
| **Infrastructure Master TOC** | `galaxyGame/docs/wiki/infrastructure/README.md` | Core industrial rules (no magic spawns, chemical hard gates, slag propellant, structural anchoring) |
| **Star System JSONs** | `galaxyGame/data/json-data/star_systems/*.json` | 48+ procedurally generated star systems with celestial body data |
| **Component Blueprint Schema** | `galaxyGame/data/schemas/component_blueprint_v1.1.json` | Blueprint data format |
| **Agent Tasks Rules** | `agent-tasks/rules/GUARDRAILS.md` | Operational guardrails (Docker, RSpec, migrations) |
| **UI Session Guidance** | `agent-tasks/projects/galaxy-game-ui/SESSION_GUIDANCE.md` | Project-specific startup, UI choices from wiki, paths/names, critical rules |
| **UI README** | `agent-tasks/projects/galaxy-game-ui/README.md` | Project scope; intended direction |

### Documentation Quality Assessment

| Area | Quality | Notes |
|------|---------|-------|
| Wiki navigation (README) | GOOD | Well-organized by category; clear status banners |
| Status & Gaps | GOOD | Honest about what's verified vs. intent; useful gap tracking |
| Core mechanics | GOOD | Comprehensive player-facing overview |
| Terraforming docs | MIXED | Sections above/below reading note have different authority levels |
| AI Manager docs | MIXED | `AI_MANAGER_INTENT.md` explicitly marks some content as exploratory |
| Infrastructure TOC | GOOD | Clear master pipeline narrative; core industrial rules well stated |
| Player wiki pages | DRAFT | Several marked as DIRECTION or OPEN; not yet verified against code |
| UI wiki page | ESTABLISHED INTENT | Branding decisions confirmed 2026-11-04 |
| Architecture docs | UNEVEN | `docs/architecture/` has 30+ files of varying age and authority |
| Star system JSONs | IMPLEMENTED DATA | 48+ systems; actual game data |

---

## D. Design and Documentation Reconciliation

### Conflicts Identified

1. **Galaxy vs. Galaxies Navigation**
   - **Code**: `Galaxy` model supports multiple galaxies (table exists, unique identifier enforced). 48+ star system JSONs exist across different systems.
   - **Wiki**: `docs/wiki/astronomy/system_blueprints.md` documents multi-system generation; `docs/wiki/technical/portals_and_aws.md` describes inter-system networking.
   - **Current UI**: Sidebar says "Galaxy" (singular) with sub-items Galaxy, Star Systems, Settlements.
   - **Resolution**: The sidebar label should be **Galaxies** (plural). Players navigate between galaxies. "Star Systems" is a child of a galaxy, not a top-level destination.

2. **Star Systems Relationship to Galaxies**
   - **Code**: `SolarSystem belongs_to :galaxy`. Star systems are children of galaxies.
   - **Current UI**: Star Systems appears as a sibling of Galaxy in the sidebar.
   - **Resolution**: Star Systems should be accessed through a galaxy, not as a top-level destination. The navigation hierarchy should reflect: Galaxies → [select galaxy] → Star Systems (within that galaxy).

3. **Settlements Relationship**
   - **Code**: Settlements belong to colonies, which belong to celestial bodies. Players own colonies.
   - **Current UI**: Settlements appears as a top-level navigation item alongside Galaxy and Star Systems.
   - **Resolution**: Settlements should be accessed through a specific colony/celestial body context, not as a global list.

4. **Terraforming Documentation Authority**
   - `docs/gameplay/terraforming.md` has a reading note (2026-10-10) dividing sections into current intent (above the note) and older/exploratory (below). This is good practice but creates confusion about which sections are authoritative.
   - **Resolution**: The sections above the reading note should be treated as current intent; below as concept history.

5. **AI Manager Intent Document**
   - `docs/architecture/ai_manager/AI_MANAGER_INTENT.md` explicitly marks some content as "exploratory" and directs readers to other docs for priority. This is honest but creates a fragmented understanding of AI Manager behavior.
   - **Resolution**: Consolidate into the canonical wiki page (`docs/wiki/logistics/ai_manager_logic.md`) which is marked as "CANONICAL FRONT DOOR."

6. **Eden System Data Issues**
   - `status-and-gaps.md` documents that Eden system data (`AOL-732356`) has physically impossible densities, mismatched star mass/type labels, and incorrect orbital periods. This is backend work that is currently paused.
   - **Resolution**: Document as a known data quality issue; do not build UI features dependent on Eden's specific data until fixed.

7. **Player Navigation vs. Actual Game Structure**
   - The current sidebar has Economy, Research, and Missions as top-level items. These are all settlement/colony-contextual operations, not global destinations. A player cannot view "the economy" globally — they view their settlement's marketplace.
   - **Resolution**: These should be contextual panels within a colony/settlement view, not top-level navigation entries.

### Missing Wiki Coverage

| Topic | Should Be Documented | Priority |
|-------|---------------------|----------|
| Player model schema | `players` table structure, `active_location`, `disconnected` state | HIGH — needed before player dashboard UI |
| Colony creation flow | How players establish colonies; validation requirements (≥2 settlements) | HIGH |
| Settlement type progression | What each settlement type unlocks | MEDIUM |
| Multi-galaxy navigation design | How players select/switch galaxies | HIGH — directly impacts current sidebar issue |
| Economy model overview | GCC, Virtual Ledger, exchange rates, market mechanics | MEDIUM |
| Wormhole traversal rules | Mass limits, decay, exotic resources, stabilization | MEDIUM |
| Player inventory system | Inventory capacity, surface storage, item types | LOW |

### Outdated Information

| Source | Issue | Action |
|--------|-------|--------|
| `docs/gameplay/mechanics.md` Victory Conditions section | Describes Economic/Tech/Exploration victory conditions that don't appear in code | VERIFY — may be aspirational |
| `docs/architecture/ai_manager/AI_MANAGER_INTENT.md` | Contains exploratory content mixed with established intent | Already self-annotated; needs consolidation into wiki |
| `docs/wiki/player/player_roles_and_alignment.md` | Marked as "verify against code" | Needs verification |
| `docs/gameplay/mechanics.md` Difficulty Levels section | Describes Beginner/Standard difficulty that doesn't appear in code | VERIFY — may be aspirational |

---

## E. Player Navigation Assessment

### Current Sidebar Structure

```
Account
  ├── Overview

Galaxy
  ├── Galaxy
  ├── Star Systems
  └── Settlements

Operations
  ├── Economy
  ├── Research
  └── Missions

Admin (conditional)
  └── Admin Console
```

### Assessment of Each Entry

| Entry | Problem | Recommendation |
|-------|---------|----------------|
| **Account → Overview** | Correct. Dashboard is the player's home. | Keep as-is. |
| **Galaxy (section header)** | Singular form is incorrect. The game supports multiple galaxies. | Change to **Galaxies**. |
| **Galaxy (item)** | Vague name; duplicates section header. No route exists for a "galaxy" view. | Remove this item. It's redundant and confusing. |
| **Star Systems** | Should be accessed through a galaxy, not as a top-level destination. `SolarSystem belongs_to :galaxy`. | Move under Galaxies → [select galaxy] → Star Systems. |
| **Settlements** | Settlements are colony-contextual. No global settlement list makes sense. | Access through Colony → Settlements context. |
| **Economy** | Economy is settlement/marketplace-specific, not a global view. | Move to Colony/Colony detail view as a panel. |
| **Research** | Research (blueprint research levels) is player-owned but tied to specific blueprints/settlements. | Move to Account → Blueprints or Colony → Manufacturing. |
| **Missions** | Missions are settlement-specific (`Mission belongs_to :settlement`). | Move to Colony → Missions panel. |

### Recommended Navigation Structure

```
Account
  ├── Overview (dashboard)
  └── Blueprints (player-owned blueprints, research levels)

Galaxies
  ├── All Galaxies (index of available galaxies)
  └── [select galaxy] → Star Systems (within that galaxy)
        └── [select system] → Celestial Bodies
              └── [select body] → Colony / Settlement details

Colony
  ├── Overview (colony dashboard)
  ├── Settlements (list of colony's settlements)
  │     └── [select settlement] → Marketplace, Manufacturing, Missions
  ├── Missions (settlement-specific missions/contracts)
  └── Economy (marketplace, logistics, trades)

Exploration
  ├── Star Systems (quick access to all systems in current galaxy)
  └── Wormhole Network (active wormholes between systems)
```

### Key Rationale

1. **Galaxies (plural)**: The `Galaxy` model exists with unique identifiers and type enum. 48+ star systems exist across different galaxies. Players should navigate between galaxies.
2. **Star Systems is a child of Galaxy**: `SolarSystem belongs_to :galaxy`. It cannot exist without a galaxy context.
3. **Settlements are colony-contextual**: Settlements belong to colonies, which belong to celestial bodies. A global "Settlements" list doesn't match the data model.
4. **Economy/Research/Missions are contextual**: These are all operations that happen at specific settlements or for specific players. They should be panels within a colony/settlement view, not top-level destinations.

---

## F. Wiki Improvement Plan

### Priority 1: Corrections to Existing Pages

| Page | Issue | Action |
|------|-------|--------|
| `docs/wiki/status-and-gaps.md` | Eden system data issues documented but no tracking task | Add to known gaps table with status "BACKEND PAUSED" |
| `docs/gameplay/mechanics.md` | Victory Conditions section not reflected in code | Mark as "ASPIRATIONAL — not implemented" banner |
| `docs/wiki/player/player_roles_and_alignment.md` | Marked VERIFY AGAINST CODE | Verify and update or remove if no code support |

### Priority 2: New Pages Needed Before UI Implementation

| Page | Purpose | Depends On |
|------|---------|-----------|
| `player/multi_galaxy_navigation.md` | How players select/switch galaxies; galaxy index page design | None — can be drafted now |
| `player/colony_management.md` | Colony creation, settlement management, colony dashboard | None — model structure is clear |
| `player/settlement_detail.md` | What a player sees at a settlement (marketplace, manufacturing, missions) | Colony management page |
| `player/blueprint_research.md` | Blueprint ownership, research levels, manufacturing pipeline | None — model structure is clear |
| `player/wormhole_network.md` | Wormhole traversal, mass limits, exotic resources, stabilization | Natural wormholes wiki page |
| `astronomy/galaxy_index.md` | What the galaxy index page shows; how galaxies relate to star systems | Multi-galaxy navigation page |

### Priority 3: Consolidation Opportunities

| Source | Target | Action |
|--------|--------|--------|
| `docs/architecture/ai_manager/AI_MANAGER_INTENT.md` (exploratory sections) | `docs/wiki/logistics/ai_manager_logic.md` | Move established intent to wiki; archive exploratory content |
| `docs/gameplay/mechanics.md` (Victory Conditions, Difficulty Levels) | Separate aspirational section or remove | Clarify status |
| `docs/wiki/infrastructure/` (multiple pre-player docs) | Already consolidated under master TOC | Good — no action needed |

### Priority 4: Documentation Before UI Implementation

**Document these BEFORE implementing their corresponding UI:**

1. **Multi-galaxy navigation design** — How players select galaxies; what the galaxy index shows
2. **Colony management flow** — How players create/manage colonies; settlement hierarchy
3. **Settlement detail page spec** — What panels appear (marketplace, manufacturing, missions)
4. **Wormhole network visualization** — How wormholes are displayed to players

---

## G. Player UI Implementation Sequence

Based on actual game functionality and established design intent:

### Phase 1: Foundation (Week 1-2)

1. **Fix sidebar navigation structure** — Change "Galaxy" to "Galaxies"; restructure hierarchy
2. **Galaxy index page** — List all available galaxies; link to star systems within each
3. **Star Systems view (within galaxy context)** — Show star systems belonging to selected galaxy
4. **Celestial Body detail** — Enhanced view showing physical properties, spheres, colonies

### Phase 2: Colony System (Week 3-4)

5. **Colony creation flow** — How players establish their first colony
6. **Colony dashboard** — Overview of all colony settlements, population, resources
7. **Settlement detail page** — Marketplace, manufacturing, missions panels
8. **Marketplace integration** — NPC pricing, buy/sell orders, logistics contracts

### Phase 3: Player Operations (Week 5-6)

9. **Blueprints & Research** — Player-owned blueprints, research levels, manufacturing queue
10. **Missions board** — Settlement-specific missions and contracts
11. **Economy overview** — GCC balance, transactions, market trends
12. **Wormhole network visualization** — Active wormholes between star systems

### Phase 4: Exploration (Week 7-8)

13. **Galaxy-to-galaxy navigation** — AWS portal travel between systems
14. **Exploration tools** — Survey, resource assessment, site selection
15. **Interstellar communications** — Data lag visualization
16. **Eden disconnect narrative integration** — Story elements in UI

---

## H. Questions Requiring User Decisions

### Decision 1: Galaxy Navigation Entry Point
The game supports multiple galaxies with 48+ star systems. Should new players:
- **A)** Start at a specific galaxy (Sol) and discover others through exploration?
- **B)** See a galaxy selection screen at entry?
- **C)** Start at an AWS station that connects to multiple galaxies?

### Decision 2: Colony Creation Trigger
The code requires colonies to have ≥2 settlements. Should:
- **A)** The first settlement be created automatically (AI Manager foothold)?
- **B)** The player creates their first settlement, then the second?
- **C)** The game provides a "starter colony" with one settlement that the player expands?

### Decision 3: Settlement Detail Page Layout
The settlement has many systems (marketplace, manufacturing, missions, logistics, inventory, base units). What should appear on the primary settlement view?
- **A)** All panels visible (dashboard-style)?
- **B)** Tabbed interface with one panel per tab?
- **C)** Contextual panels that change based on settlement type (base vs. station)?

### Decision 4: Economy Visibility Scope
The economy has multiple layers (GCC balance, Virtual Ledger, NPC market prices, exchange rates). What should players see?
- **A)** Only GCC and their own transactions (simplified)?
- **B)** GCC + NPC market prices (transparent)?
- **C)** Full economy with exchange rates and Virtual Ledger visibility (complex)?

### Decision 5: Wormhole vs. Portal Terminology
The wiki uses both "wormhole" (existing model) and "portal" (design intent for low-mass intra-system travel). Should the player-facing UI use:
- **A)** "Wormhole" (matches existing model)?
- **B)** "Portal" (matches design intent for low-mass travel)?
- **C)** Both, with context-specific usage?

### Decision 6: Eden System Data Status
The Eden system (`AOL-732356`) has known data quality issues (impossible densities, mismatched labels). Should the UI:
- **A)** Hide Eden until backend fixes are applied?
- **B)** Display it with a "data incomplete" indicator?
- **C)** Proceed with UI implementation using placeholder data?

---

## Appendix: Key File Paths Reference

### Main Game (galaxyGame)

| Category | Path |
|----------|------|
| Galaxy model | `galaxy_game/app/models/galaxy.rb` |
| SolarSystem model | `galaxy_game/app/models/solar_system.rb` |
| CelestialBody base | `galaxy_game/app/models/celestial_bodies/celestial_body.rb` |
| Player model | `galaxy_game/app/models/player.rb` |
| Colony model | `galaxy_game/app/models/colony.rb` |
| Settlement model | `galaxy_game/app/models/settlement/base_settlement.rb` |
| Schema | `galaxy_game/db/schema.rb` |
| Routes (main game) | `galaxy_game/config/routes.rb` |
| Game controller | `galaxy_game/app/controllers/game_controller.rb` |
| SolarSystems controller | `galaxy_game/app/controllers/solar_systems_controller.rb` |
| CelestialBodies controller | `galaxy_game/app/controllers/celestial_bodies_controller.rb` |
| Services directory | `galaxy_game/app/services/` (100+ services) |
| Star system JSONs | `data/json-data/star_systems/*.json` |
| Wiki home | `docs/wiki/README.md` |
| Status & gaps | `docs/wiki/status-and-gaps.md` |
| Core mechanics | `docs/gameplay/mechanics.md` |
| Terraforming design | `docs/gameplay/terraforming.md` |
| Player experience | `docs/gameplay/player_experience_boundaries.md` |
| AI Manager intent | `docs/architecture/ai_manager/AI_MANAGER_INTENT.md` |
| Architecture overview | `docs/architecture/overview.md` |
| UI branding intent | `docs/wiki/ui/01_branding_and_entry_experience.md` |
| First hour entry | `docs/wiki/player/first_hour_and_entry_state.md` |
| Eden disconnect | `docs/wiki/player/eden_disconnect_and_emergent_history.md` |
| Settlement progression | `docs/wiki/player/settlement_progression_and_footholds.md` |
| Portals & AWS | `docs/wiki/technical/portals_and_aws.md` |
| Infrastructure TOC | `docs/wiki/infrastructure/README.md` |

### UI Prototype (galaxy-game-ui)

| Category | Path |
|----------|------|
| Routes | `galaxy-game-ui/config/routes.rb` |
| Dashboard layout | `galaxy-game-ui/app/views/layouts/dashboard.html.erb` |
| Application layout | `galaxy-game-ui/app/views/layouts/application.html.erb` |
| Dashboard controller | `galaxy-game-ui/app/controllers/dashboard_controller.rb` |
| Landing controller | `galaxy-game-ui/app/controllers/landing_controller.rb` |
| Sessions controller | `galaxy-game-ui/app/controllers/sessions_controller.rb` |
| Admin dashboard | `galaxy-game-ui/app/controllers/admin/dashboard_controller.rb` |
| Tailwind tokens | `galaxy-game-ui/app/assets/tailwind/application.css` |
| Design tokens CSS | `galaxy-game-ui/app/assets/stylesheets/tokens.css` |
| Dashboard CSS | `galaxy-game-ui/app/assets/stylesheets/pages/dashboard.css` |
| Landing CSS | `galaxy-game-ui/app/assets/stylesheets/pages/landing.css` |

### Agent Tasks

| Category | Path |
|----------|------|
| Guardrails | `agent-tasks/rules/GUARDRAILS.md` |
| UI README | `agent-tasks/projects/galaxy-game-ui/README.md` |
| Session guidance | `agent-tasks/projects/galaxy-game-ui/SESSION_GUIDANCE.md` |

---

*End of audit report. No changes made to either repository.*
