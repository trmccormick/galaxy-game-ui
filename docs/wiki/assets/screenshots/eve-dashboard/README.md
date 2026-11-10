# EVE Dashboard — Visual Reference Documentation

**Collection date:** 2026-11-08  
**Source:** Source code review of previously examined JavaScript files (no live EVE Dashboard access)  
**Status:** Code-based observations only — not visually verified from the live product

---

## Access Limitation

Live access to the EVE Online client or EVE Dashboard web interface was **not available** during this documentation session. The following observations are derived entirely from:

1. Previously examined JavaScript source files in earlier sessions
2. Existing wiki documentation that references EVE patterns
3. General knowledge of EVE Online's established UI conventions (as of 2024)

These observations should be treated as **hypotheses to verify**, not confirmed behavior. If live access becomes available, these notes should be validated or corrected against the actual product.

---

## Documented Reference Files

The following JavaScript files were previously examined as interaction references:

| File | Source context | What was documented |
|------|---------------|---------------------|
| `fleet_map.js` | JavaScript from a previously examined EVE-related dashboard application (fleet management) | SVG map interactions, pan/zoom, markers, routes, tooltips, context menus, shortest-path logic |
| `market.js` | JavaScript from a previously examined EVE-related dashboard application (market window) | Searchable/filterable table, sorting, summary metrics, refresh behavior |
| `chain.js` | JavaScript from a previously examined EVE-related dashboard application (wormhole chain visualization) | Interactive network graph, node/link editing, zoom/pan, contextual details |
| `assets.js` | JavaScript from a previously examined EVE-related dashboard application (asset manager) | Multi-select filters, select-all/none, indeterminate state, typeahead |
| `wealth.js` | JavaScript from a previously examined EVE-related dashboard application (wallet/transaction history) | Analytics chart, grouping, filters, shared selection, transaction drill-down |
| `structures.js` | JavaScript from a previously examined EVE-related dashboard application (structure management) | Delegated clipboard actions and feedback |

These files were reviewed in earlier sessions (prior to 2026-11-08). Their exact source paths, versions, and current state in any repository should be re-verified before use.

---

## Patterns Worth Evaluating (Code-Derived)

### Navigation and Wayfinding
**What EVE does:** Global navigation bar with workspace-specific secondary navigation. Context selectors for fleet/singleton views. Breadcrumb-style location indicators.

*Note: These navigation observations are general knowledge of EVE Online's established interface conventions, not findings derived from the six JavaScript files.*

**Why it appears useful:** Players can always see their current workspace and return to common destinations without losing context.

**Galaxy Game adaptation:** The sidebar pattern observed in the current Galaxy Game prototype (Account/Galaxy/Operations/Admin sections) aligns with this approach. Whether EVE's global bar or Galaxy Game's sidebar better serves the game's information architecture is an open question.

### Map Interactions
**What EVE does:** SVG-based map with pan/zoom, marker selection, hover tooltips, route overlays, and layer toggles. Selected objects show detail panels alongside the map.

**Dependencies:** Requires SVG rendering library (or custom canvas), coordinate system for star positions, route data from EVE APIs.

**Galaxy Game adaptation:** The fleet_map.js patterns are directly relevant to the Galaxy Game system map workspace concept. Coordinate systems and object types must be replaced with Galaxy Game's own data model.

### Table Interactions
**What EVE does:** Sortable columns, search filtering, category filters, multi-select rows, summary metrics above/below the table, refresh buttons. Selected rows highlight and update detail panels.

**Dependencies:** Client-side sorting/filtering logic, server-side pagination for large datasets, event delegation for row actions.

**Galaxy Game adaptation:** The market.js patterns are strong candidates for the Galaxy Game market/economy workspace and any data-heavy player screens (assets, settlements, missions).

### Network Visualization
**What EVE does:** Force-directed or manual-layout graph with draggable nodes, clickable edges, zoom/pan, node detail panels on selection, link state indicators.

**Dependencies:** Graph layout algorithm, edge routing logic, node/edge data structures specific to EVE's wormhole system.

**Galaxy Game adaptation:** The chain.js patterns could inform Galaxy Game's logistics/network visualization, but only if a real workflow requires it. Wormhole topology must come from Galaxy Game's own rules.

### Analytics and Charts
**What EVE does:** Time-series charts with date range selectors, grouping controls, linked table selection (clicking a chart region filters the table), drill-down to transaction details.

**Dependencies:** Charting library (likely D3.js or custom), time-window aggregation logic, shared selection state management.

**Galaxy Game adaptation:** The wealth.js patterns could inform economy/finance analytics after backend data contracts exist. Not a first-slice dependency.

---

## What Must NOT Be Imported from EVE

- EVE terminology (fleet, corporation, alliance, PLEX, etc.)
- EVE's game-domain hierarchy and faction structure
- EVE's economic rules and market mechanics
- EVE's navigation labels and feature grouping
- EVE's visual styling (specific color palettes, icons, branding)
- EVE's permission model and access controls
- Any assumption that EVE's information density is appropriate for Galaxy Game

---

## Recommended Next Steps for EVE Reference Documentation

1. **If live access becomes available:** Capture genuine screenshots of the EVE Dashboard navigation, map workspace, market window, asset manager, and wealth/transaction views. Document each with viewport, interaction tested, and relevant source context.

2. **Verify code-derived observations:** Compare the previously examined JavaScript files against the source of that same EVE-related dashboard application to confirm patterns are still applicable.

3. **Connect to Galaxy Game wiki pages:** Each pattern above should be linked to the relevant screen concept in `screen-concepts-and-wireframes.md` and the JS reuse plan in `javascript-reuse-and-porting-plan.md`.

---

## Related Wiki Pages

- [Interface Pattern References](../../../interface-pattern-references.md)
- [JavaScript Reuse, Porting, and Module Plan](../../../javascript-reuse-and-porting-plan.md)
- [Screen Concepts and Wireframes](../../../screen-concepts-and-wireframes.md)
- [Visual Reference and Screenshot Plan](../../../visual-reference-and-screenshot-plan.md)
