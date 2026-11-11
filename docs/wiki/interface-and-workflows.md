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

## 8. References

- [Project overview and architecture](README.md)
- [Data integration and migration direction](data-integration-and-migration.md)
- [First-attempt reconciliation](first-attempt-reconciliation.md)
- [Screenshot evidence](assets/screenshots/galaxy-game-ui/README.md) — captured 2026-11-08
- [EVE Dashboard reference](assets/screenshots/eve-dashboard/README.md) — code-derived observations
- Main game's UI/domain wiki: `galaxyGame/docs/wiki/` (consult the current repository version; do not duplicate its domain definitions here).
