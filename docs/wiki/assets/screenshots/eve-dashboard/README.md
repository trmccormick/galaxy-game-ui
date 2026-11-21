# EVE Dashboard — Visual Reference Documentation

**Collection date:** 2026-11-08  
**Last updated:** 2026-11-19
**Source:** User-shared JavaScript from the owner's independently developed Python EVE Dashboard application  
**Status:** Code-based observations only — not visually verified from the live product

---

## Application identity and evidence limits

EVE Dashboard is the owner's independently developed Python application, shared by the user for inspection and possible collaboration. It connects to the EVE Online API; it is not EVE Online itself and is not an official EVE Online interface. The application and its source are a separate reference from the game/API it connects to.

The observations below are derived from the user-shared JavaScript files previously examined, not from a live inspection of the running application. Treat them as code-derived observations about those supplied files, not a complete description of the application. Do not use general EVE Online UI conventions as evidence of how EVE Dashboard behaves.

The shared JavaScript may be copied and adapted in the GalaxyGame prototype for testing. Keep provenance and dependency notes. Prototype copying does not establish ownership or production redistribution rights; review applicable licenses and permissions before production use. Generic interaction patterns may also be independently implemented.

---

## Documented Reference Files

The following JavaScript files were previously examined as interaction references:

| File | Source context | What was documented |
|------|---------------|---------------------|
| `fleet_map.js` | JavaScript from the user's shared EVE Dashboard application (fleet management) | SVG map interactions, pan/zoom, markers, routes, tooltips, context menus, shortest-path logic |
| `fleet_builder.js` | User-supplied JavaScript from the EVE Dashboard reference | Character/team selection, grouping, ordering, favourites, quick actions, localStorage preferences, EVE-specific endpoints; candidate interaction mechanics only |
| `fleet.js` | User-supplied JavaScript from the EVE Dashboard reference | EVE waypoint form handling and fleet endpoint submission; low reuse potential beyond generic form interaction patterns |
| `market.js` | JavaScript from the user's shared EVE Dashboard application (market window) | Searchable/filterable table, sorting, summary metrics, refresh behavior |
| `chain.js` | JavaScript from the user's shared EVE Dashboard application (wormhole chain visualization) | Interactive network graph, node/link editing, zoom/pan, contextual details |
| `assets.js` | JavaScript from the user's shared EVE Dashboard application (asset manager) | Multi-select filters, select-all/none, indeterminate state, typeahead |
| `wealth.js` | JavaScript from the user's shared EVE Dashboard application (wallet/transaction history) | Analytics chart, grouping, filters, shared selection, transaction drill-down |
| `structures.js` | JavaScript from the user's shared EVE Dashboard application (structure management) | Delegated clipboard actions and feedback |

The original six reference files were reviewed before 2026-11-08. Additional user-supplied files fleet_builder.js and fleet.js were inspected on 2026-11-19. Exact original source paths/revisions and current prototype copies must still be re-verified before implementation.

---

## Patterns Worth Evaluating (Code-Derived)

### Navigation and Wayfinding
**Candidate pattern to inspect:** Global navigation, workspace-specific secondary navigation, context selectors, and breadcrumb-style location indicators. These are not confirmed by the supplied JavaScript files.

*Evidence note: The supplied JavaScript does not establish the EVE Dashboard application's global navigation. Do not infer the friend's app navigation from EVE Online's own interface; verify it from the running Dashboard application if access becomes available.*

**Why it appears useful:** Players can always see their current workspace and return to common destinations without losing context.

**Galaxy Game adaptation:** The sidebar pattern observed in the current Galaxy Game prototype (Account/Galaxy/Operations/Admin sections) aligns with this approach. Whether a persistent global navigation bar or GalaxyGame's existing sidebar better serves the game's information architecture is an open question.

### Map Interactions
**What the supplied EVE Dashboard code demonstrates:** SVG-based map with pan/zoom, marker selection, hover tooltips, route overlays, and layer toggles. Selected objects show detail panels alongside the map.

**Dependencies:** Requires SVG rendering library (or custom canvas), coordinate system for star positions, route data from EVE APIs.

**Galaxy Game adaptation:** The fleet_map.js patterns are directly relevant to the Galaxy Game system map workspace concept. Coordinate systems and object types must be replaced with Galaxy Game's own data model.

### Craft selection and operational grouping
**What the supplied fleet_builder.js does:** Provides selection and grouping interactions around EVE character/team records, with ordering, favourites, localStorage preferences, quick actions, and EVE-specific endpoints.

**Galaxy Game adaptation:** Reuse only suitable interaction mechanics. The primary records are named GalaxyGame craft/ships, not pilots or characters. Craft are autonomous assets commanded remotely; players and Admin/AI Manager workflows assign objectives, while onboard automation and the AI Manager support execution according to craft capabilities and available communications. A craft may operate independently or be grouped for a particular task/operation; do not assume every craft belongs to a standing fleet. Player asset management and Admin/AI Manager oversight remain distinct workflows. Do not reuse EVE character/team schemas, localStorage conventions, fleet endpoints, or fleet gameplay rules.

### Table Interactions
**What the supplied EVE Dashboard code demonstrates:** Sortable columns, search filtering, category filters, multi-select rows, summary metrics above/below the table, refresh buttons. Selected rows highlight and update detail panels.

**Dependencies:** Client-side sorting/filtering logic, server-side pagination for large datasets, event delegation for row actions.

**Galaxy Game adaptation:** The market.js patterns are strong candidates for the Galaxy Game market/economy workspace and any data-heavy player screens (assets, settlements, missions).

### Network Visualization
**What the supplied EVE Dashboard code demonstrates:** Force-directed or manual-layout graph with draggable nodes, clickable edges, zoom/pan, node detail panels on selection, link state indicators.

**Dependencies:** Graph layout algorithm, edge routing logic, node/edge data structures specific to EVE's wormhole system.

**Galaxy Game adaptation:** The chain.js patterns could inform Galaxy Game's logistics/network visualization, but only if a real workflow requires it. Wormhole topology must come from Galaxy Game's own rules.

### Analytics and Charts
**What the supplied EVE Dashboard code demonstrates:** Time-series charts with date range selectors, grouping controls, linked table selection (clicking a chart region filters the table), drill-down to transaction details.

**Dependencies:** Charting library (likely D3.js or custom), time-window aggregation logic, shared selection state management.

**Galaxy Game adaptation:** The wealth.js patterns could inform economy/finance analytics after backend data contracts exist. Not a first-slice dependency.

---

## What Must NOT Be Imported from EVE

- EVE Online terminology and game concepts (corporation, alliance, PLEX, and game-specific fleet semantics); retain only generic words when they accurately describe GalaxyGame concepts.
- EVE Online's game-domain hierarchy and faction structure
- EVE Online's economic rules and market mechanics
- EVE Online's navigation labels and feature grouping
- EVE Online's visual styling (specific color palettes, icons, branding)
- EVE Online's permission model and access controls
- Any assumption that EVE Online's information density is appropriate for GalaxyGame

---

## Recommended Next Steps for EVE Reference Documentation

1. **If live access to the EVE Dashboard application becomes available:** Capture genuine screenshots of the EVE Dashboard navigation, map workspace, market window, asset manager, and wealth/transaction views. Document each with viewport, interaction tested, and relevant source context.

2. **Verify code-derived observations:** Compare the previously examined JavaScript files against the source of the EVE Dashboard application to confirm patterns are still applicable.

3. **Connect to Galaxy Game wiki pages:** Each pattern above should be linked to the relevant screen concept in `screen-concepts-and-wireframes.md` and the JS reuse plan in `javascript-reuse-and-porting-plan.md`.

---

## Related Wiki Pages

- [Interface Pattern References](../../../interface-pattern-references.md)
- [JavaScript Reuse, Porting, and Module Plan](../../../javascript-reuse-and-porting-plan.md)
- [Screen Concepts and Wireframes](../../../screen-concepts-and-wireframes.md)
- [Visual Reference and Screenshot Plan](../../../visual-reference-and-screenshot-plan.md)
