# Interface and Workflow Direction

**Status:** Working direction — for owner review  
**Last updated:** 2026-11-08  
**Scope:** Application interface, player/admin workflows, navigation and screen responsibilities.

This page describes the interface direction for the new Galaxy Game UI. It is not a final screen specification, visual design system, or implementation task list.

## 1. Product distinction: player interface and admin console

The application may contain more than one audience and workspace. Keep the purposes separate.

### Player-facing experience

The player interface supports a person operating within the game world. It should help the player understand their current context, inspect assets and activity, make decisions, and initiate permitted actions.

Potential workflow areas to explore include:
- current location and player status;
- assets, craft, units and inventories;
- markets, orders and transactions;
- research and manufacturing;
- missions, contracts and other opportunities;
- logistics, routes and transportation;
- celestial-body inspection and surface operations.

This is a capability inventory, not an approved global navigation list. Each area must be grounded in current game behavior, source data and actual player workflows before a screen is specified.

### Admin console

The admin console is an operational and administrative interface for observing and managing the application/game environment. It is not the player's dashboard with extra controls.

Potential concerns include system health, user administration, operational telemetry, NPC/AI Manager oversight, data integrity and administrative actions. The actual scope and permissions must be verified against the application's authentication/authorization design and game operations.

Do not transfer player entry-state assumptions, player asset workflows, or gameplay onboarding directly into the Admin console. Conversely, do not treat an admin telemetry panel as a player-facing game feature.

## 2. Navigation principles

**Established direction:** use EVE Online's dashboard/navigation approach as an information-architecture reference, not as a source of Galaxy Game concepts or rules.

- Make important destinations quick to reach and discoverable.
- Do not mirror the database or game-domain hierarchy as a deeply nested primary sidebar.
- Use global destinations for genuinely global workflows.
- Use contextual selectors, maps, page content and feature-specific secondary navigation to express relationships.
- A relationship such as galaxy → star system → celestial body should be navigable in context; it does not automatically require three nested primary-menu levels.
- Preserve useful global destinations when a user is viewing a specific location.
- Do not assume economy, research or missions are exclusively global or settlement-only. Their placement should follow the actual ownership, scope and workflow in the game.
- Do not finalize the navigation list from the old first-attempt menu proposals.

### Navigation reference pattern

A useful pattern to evaluate is:

1. **Primary navigation:** a small set of broad, frequently used destinations.
2. **Context selection:** choose or display the current galaxy, system, body, settlement, structure or other relevant scope when the workflow requires it.
3. **Page-level navigation:** tabs, filters or secondary navigation for the current feature.
4. **Content workspace:** the main map, table, dashboard, chart, detail view or operational controls.

This is a conceptual pattern, not a prescribed component tree.

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

## 7. References

- [Project overview and architecture](README.md)
- [Data integration and migration direction](data-integration-and-migration.md)
- [First-attempt reconciliation](first-attempt-reconciliation.md)
- Main game's UI/domain wiki: `galaxyGame/docs/wiki/` (consult the current repository version; do not duplicate its domain definitions here).
