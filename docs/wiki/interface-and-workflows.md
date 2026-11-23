# Interface and Workflow Direction

**Status:** Prototype guidance aligned to established product intent  
**Last updated:** 2026-11-11  
**Scope:** Application interface, player/admin workflows, navigation and screen responsibilities.

This page describes the interface direction for the new Galaxy Game UI. It is not a final screen specification, visual design system, or implementation task list.

## 1. Three application interfaces

The product has three distinct interfaces. They share a visual language but have different audiences, responsibilities, and workflows.

### Main Game / Player interface

The player interface supports a person operating within the shared game world. It helps the player understand current context, inspect assets and activity, make decisions, and initiate permitted actions. Its five views (Planetary, Surface, Settlement, Space, Galaxy) are defined in the main game's `galaxyGame/docs/wiki/ui/02_player_view_architecture.md` (canonical product intent).

### Admin console

The Admin interface is an operational and administrative workspace for observing, configuring, and validating the game environment. It is not the player's dashboard with extra controls. Its areas include simulation/world-state oversight, infrastructure, system health, data integrity, planetary data, and Map Studio / Digital Twin workflows.

### AI Manager interface

The AI Manager interface is an operator-supervision workspace for missions, plans, decisions and their rationale, resource priorities and shortages, asset deployments, execution progress, warnings, intervention, and retained training/validation evidence. Early main-game views are starting references, not a mature UI to copy wholesale.

**Current prototype priority:** Admin and AI Manager before Player. Mock data is acceptable during UI development, but screens and controls must clearly distinguish mock presentation from operations connected to live services.

The three interfaces should share the design system without being forced into identical layouts or navigation.

## 1A. Workflow boundaries

Player workflows, administrative operations, and AI Manager supervision remain distinct. Reuse of a visualization or data source does not merge audiences or grant permissions. The application/backend remains authoritative for access and permitted operations.

## 2. Navigation and information architecture

**ESTABLISHED DIRECTION — 2026-11-11**

Use EVE-style desktop navigation and workspace organization as a reference for information architecture and interaction patterns, not as a source of Galaxy Game concepts, rules, or visual styling.

- Make important destinations quick to reach and discoverable.
- Do not mirror the database or game-domain hierarchy as a deeply nested primary sidebar.
- Use global destinations for genuinely global workflows.
- Use contextual selectors, maps, page content, and feature-specific secondary navigation to express relationships.
- A relationship such as galaxy → star system → celestial body should be navigable in context; it does not automatically require three nested primary-menu levels.
- Use the right interface pattern for the task: catalog/table, map, dashboard, comparison, detail pane, or operational workspace. Do not force every screen into large cards or one dashboard template.
- Use compact, information-dense tables and lists where users need to browse or compare many objects. Use selection, drill-down, contextual actions, and detailed analysis for deeper work.
- Make assumptions, data scope, source, and relevant inputs visible when they affect a result.

### System and celestial-body workflow

A useful contextual progression is:

1. Galaxy/system catalog with compact rows and system-level assessments or counts.
2. Selected system workspace showing overview, celestial bodies, activity, and relevant assessment.
3. Selected celestial-body analysis with resources, conditions, comparisons, assumptions, and available operations.
4. The appropriate body-specific workspace/view for the task.

EVE PI Planner demonstrates a useful list → assessment → detailed planet-analysis pattern. Its terminology and Colony concepts do not map to Galaxy Game and must not be copied.

### Navigation reference pattern

A useful conceptual pattern is:

1. **Primary navigation:** a small set of broad, frequently used destinations.
2. **Context selection:** choose or display the current galaxy, system, body, settlement, structure, or other relevant scope.
3. **Page-level navigation:** tabs, filters, or secondary navigation for the current feature.
4. **Content workspace:** the map, table, comparison, dashboard, chart, detail view, or operational controls appropriate to the task.

Preserve useful global destinations while a user is viewing a specific location. Do not assume economy, research, or missions are exclusively global or settlement-only; placement should follow actual ownership, scope, and workflow. The final menu and component tree remain subject to review.

## 3. Context and location

A user's current physical/game location, the selected object in a map or browser, and the scope of a data query may be different things. The UI should not collapse them into one implicit state.

When a screen depends on context, make the scope visible. Examples include:
- current player location versus selected celestial body;
- local inventory versus remote inventory;
- local market versus a market at another structure;
- current-system information versus delayed remote-system information;
- an asset's physical location versus the page currently being viewed.

The exact rules for each workflow must come from the main game's current code/data and established domain intent. Do not invent location or ownership semantics to simplify a screen.

## 4. Existing world-inspection capabilities

The main game has a solar-system view and celestial-body inspection concepts including Monitor, Planetary and Surface layers. These are important reference capabilities.

The new UI should investigate how to make those capabilities clear and usable, while retaining their domain meaning. Do not assume that the old screen structure must be copied literally, nor that a new dashboard should replace these specialized views.

Maps and spatial views should be treated as meaningful workspaces, not decorative backgrounds. Where useful, they may connect selection, contextual details, routes, overlays and related lists.

## 5. Data age and communications

Screens that display remote or cross-system information must not imply instantaneous interstellar communication.

The current game intent distinguishes:
- light-speed communication with distance-based delay inside a system;
- inter-system store-and-forward communication through craft and WS/AWS stations;
- physical transportation through wormholes, which is distinct from electromagnetic messaging.

Where a workflow displays remote information, the UI may need to show its age, last update or delivery state. The exact fields and behavior must be based on implemented data/services; do not fabricate live message-delivery status.

## 6. Screen design record

Before a screen becomes an implementation proposal, record:

| Question | Required treatment |
|---|---|
| Audience | Player, admin, or both with clearly separated modes |
| User goal | The task the person is trying to complete |
| Context | Current location, selected object and data scope |
| Source of truth | Relevant code, JSON, operational data and domain wiki |
| Data freshness | Local/current, remote/delayed, cached, or unknown |
| Actions | Read-only, presentation state, or backend operation |
| Dependencies | Established intent, direction, and open decisions |
| Empty/error states | What appears when data or capability is unavailable |

If an important dependency is only DIRECTION or OPEN, identify it explicitly. Do not silently turn it into an established game rule.

## 7. Product-domain boundaries

The prototype must preserve the main game's distinctions among Settlements, Colonies, corporations, and players. A Settlement is a physical inhabited/developed place; a Colony is a governing political entity; a corporation or player may own a Settlement that is governed by a Colony. Ownership, governance, operations, maintenance, and funding are separate relationships. Do not represent a Settlement as simply owned by its governing Colony or import EVE PI Planner's Colony model.

The authoritative details, including the corporate-withdrawal control-transfer rule and unresolved asset/liability mechanics, belong in the main game's `galaxyGame/docs/wiki/player/settlement_ownership_and_governance.md` (canonical domain intent) page.

## 7A. Public landing page and system overview

The public landing page is the entry point to GalaxyGame and should introduce the game while making its current multi-system setting understandable. It is a public-facing entry experience, not the authenticated player dashboard and not an Admin/AI Manager workspace.

### Page layout

Use this overall content order:

1. **Brand/hero area:** GalaxyGame identity, a concise description of the game, and clear Sign In / account-entry actions. Keep this restrained so the system overview remains the main content.
2. **Star-system overview:** a prominent overview populated from current, live application data—not a hard-coded catalog or a static snapshot. Sol is the fixed baseline and should always be represented. Other systems are dynamic: the set may expand as systems are generated, introduced, or connected, and a system's current accessibility may change as natural-wormhole connections become available or unavailable. Identify systems from supplied records and show current connection/accessibility only when authoritative live data provides it. Do not assume that every known/generated system is currently reachable, or that a natural-wormhole connection guarantees continuous access. Use compact, consistent system rows/cards or equivalent panels; avoid oversized decorative cards that waste space.
3. **System network context:** communicate that the setting includes natural and artificial wormhole connections, but do not present the network as fixed. Natural wormholes can shift through their lifecycle or be deliberately shifted with the Hammer Protocol; artificial routes can be disconnected and reassigned. A shift can open a new survey opportunity: the AI Manager announces missions, players explore, and survey results determine whether the new system is a valuable prize worth integrating. For a selected frontier, the AI Manager plans AWS placement and construction while natural access remains open, then reassigns an existing Sol-side AWS route to the new station and can retarget the displaced route elsewhere. A system not selected for permanent AWS reconnection or settlement may remain accessible through a natural wormhole stabilized by satellites, allowing players to keep harvesting it for as long as the AI Manager chooses to maintain access. The AI Manager may later use the Hammer Protocol or remove the satellites and allow natural degradation. Build any network diagram from current authoritative connection state so it reflects these changes. Show current availability rather than treating known, historical, or configured connections as permanently active. Sol is the fixed baseline, not a guarantee of fixed routes.
4. **Supporting public information:** concise explanatory content and any secondary public links. Do not let secondary status panels compete with the system overview.

The visual language should follow the prototype's established dark/cyan desktop style, with compact typography, readable spacing and clear separation between system identity, connection type and supporting metadata. This is a landing page, not an attempt to reproduce an EVE Online interface.

### System-card data and meaning

Populate the overview from the current authoritative/live data source through the data-access approach described in [Data Integration and Backend Integration Proposal](data-integration-and-migration.md). The landing page must discover the current system set dynamically; do not hard-code a list, count, generated identifier, or filename. Sol is the fixed baseline. Other systems may be added over time, and their presence in the data source must not be confused with current player accessibility. Where live connection data exists, reflect whether a system is currently reachable; natural-wormhole access may be intermittent and must not be presented as permanently available merely because a connection is known. The card identity and any displayed counts must come from supplied records. A card may show concise system-level facts actually present in the source; do not fabricate population, economy, discovery or operational status.

The landing page and system views should consume system records through the main game's API. For local development/testing only, the Docker read-only mount can expose the main game's `data/json-data/` files; use the existing `sol-complete.json` and `sol.json` there when testing different collection sizes. Do not copy either file into this repository or maintain a prototype-specific system catalog. Neither file contains terrain. Do not show a terrain/map preview or infer map completeness from these files.

Keep static illustrative dashboard metrics, recent activity or other non-source content clearly identified as illustrative/mock. The presence of JSON-backed system cards does not make unrelated metrics live.


### System data, completeness, and discovery

The game is unfinished and its system-generation model is still evolving. The wiki records current understanding and open questions as work exposes them; it must not turn exploratory discussion into an assumed finalized architecture.

A system JSON file is **starting information, not necessarily a complete playable system or exhaustive inventory**:

- Sol is the only fixed, manually authored baseline, but its representation is incomplete too. StarSim may add further objects/details to Sol.
- Every other system starts from incomplete information. This includes real systems with extensive known astronomical data, real systems with sparse known data, and generated starting conditions.
- StarSim uses available information to complete and populate a playable system. Generated/completed output is still not necessarily exhaustive.
- Survey missions help add newly discovered objects and details over time and may support further spawning/addition. The exact mechanics and distinction between simulated existence, spawning, discovery, and player-visible knowledge must follow the main game's evolving implementation.

The UI must not equate the contents of an input JSON file with everything that exists in a system, or equate everything represented in simulation with everything a player has discovered. It must also distinguish system existence/record availability from current accessibility to the player: a system may be known to the application without being currently reachable, and a natural-wormhole route may not remain continuously accessible. The landing page should derive the current accessible/reachable state from live authoritative connection data when available. Do not imply that the prototype itself performs StarSim completion, survey discovery, or scientific reconciliation.

The main game's current `data/json-data/star_systems/` directory contains Sol and real-system records with varying amounts of information; all non-Sol records are incomplete starting information for StarSim. `generated_star_systems/` contains generated/completed outputs, not guaranteed exhaustive catalogs. The physical directory organization is provisional and may be refined later; do not prescribe a migration or assume that every source file is a playable system.

### Connection context

The wormhole network is dynamic by design; it is not a fixed topology or a permanent list of routes.

- **Natural wormholes** can shift over time, changing their positions and the systems/locations they connect. Their route availability must be treated as time-dependent. Stabilization satellites can maintain a natural connection for continued harvesting; the AI Manager may keep it open as long as it chooses, then either invoke the Hammer Protocol or remove the satellites and let it degrade naturally.
- **Artificial wormholes** can be shut down and retargeted. This deliberately changes the connection endpoints and can reorganize the available routes through the network. An existing Sol-side AWS route may be reassigned to connect a newly scouted frontier system, with the displaced route retargeted to another system.
- This supports a strategic expansion pattern: scout a virgin system through a natural wormhole, establish an AWS there when settlement/resource value justifies it, then connect it to Sol's developed industrial/logistics base. The AWS corridor can move personnel, ships, equipment, construction materials, and supplies more quickly, supporting settlement and resource extraction.
- The current network must therefore be derived from authoritative, current connection state, not from a static diagram, system JSON, historical connection list, or hard-coded four-edge topology.
- The landing page should distinguish natural versus artificial connections and communicate current availability/state when that data is supplied. A connection record, known anchor, or historical route does not prove that the route is currently active or traversable.
- Network views should be able to reflect route changes over time. Do not imply that the system set itself is fixed merely because Sol is the fixed baseline; systems and routes are separate data concerns.
- Exact fields, update cadence, route-history presentation, and the runtime mechanics that move natural wormholes or shut down/retarget artificial ones remain implementation details to verify against the evolving game code.

## 8. References

- [Project overview and architecture](README.md)
- [Data integration and migration direction](data-integration-and-migration.md)
- [First-attempt reconciliation](first-attempt-reconciliation.md)
- [Screenshot evidence](assets/screenshots/galaxy-game-ui/README.md) — captured 2026-11-08
- [EVE Dashboard reference](assets/screenshots/eve-dashboard/README.md) — code-derived observations
- Main game's UI/domain wiki: `galaxyGame/docs/wiki/` (consult the current repository version; do not duplicate its domain definitions here).

## 9. Existing application views: port and improve, do not start over

**ESTABLISHED REVIEW PRINCIPLE — 2026-11-11**

The main Galaxy Game application contains substantial useful interface work. It is unfinished and inconsistent in places, but it is not an empty legacy shell and its existing views are not disposable. The prototype should consolidate and complete this work while establishing a more consistent presentation.

Review and carry forward useful existing view setups and capabilities, including:

- **Planetary / Orbital:** preserve the useful planetary and orbital context, layer/data presentation, map controls, and inspection panels. Verify whether these are separate views or related perspectives before deciding how to organize them.
- **Surface:** preserve the tile-based surface workspace, terrain/geographic presentation, and useful selection and inspection interactions. Track loading/rendering defects separately from the view's intended design.
- **Map Studio:** preserve existing map generation, reconstruction, and inspection workflows as an Admin tool feeding the shared planetary Digital Twin.
- **Monitor and world inspection:** retain useful overview, navigation, selection, and contextual-action patterns.
- **Resources and infrastructure:** retain operational views that expose meaningful game data and workflows.
- **Other existing visualizations:** assess each on its merits; do not replace a specialized useful view with a generic dashboard just to make pages look alike.

This is a candidate inventory, not a claim that every view is currently complete or operational. Verify the current code and running behavior, and record the status of each view as working, incomplete, broken, or not yet assessed.

For each view, compare the main-app version with the prototype: what information and behavior already exist, what should be preserved, what is missing or broken, and what visual/interaction changes improve it. Preserve useful functionality and information architecture before refactoring. Standardize typography, spacing, controls, navigation, terminology, and status treatment without forcing every view into the same layout.

The goal is **consolidation, completion, and consistency—not wholesale replacement or reinvention.**

## 10. UI-first review and eventual integration

Use the prototype to establish the visual language, layout conventions, navigation, and interactions for these views. Mock or JSON-backed data is acceptable while the presentation is being reviewed, provided it is clearly distinguished from live game state and actions.

Once the UI is sufficiently settled, evaluate two integration paths:

1. Backport the refined views and shared presentation components into the main application, reusing its existing behavior and services.
2. Keep the prototype as the UI application and expose suitable main-application capabilities through an API that the prototype consumes.

Do not choose between these paths prematurely. The main application remains authoritative for simulation state, domain rules, calculations, authorization, and operations. Prefer reusing existing services and data access; do not duplicate game logic in the prototype or treat mock data as an API contract.

This review process should document both sides: what the main application already offers and what the prototype should improve. That record will make a later backport/API decision evidence-based rather than requiring the work to be rediscovered.
