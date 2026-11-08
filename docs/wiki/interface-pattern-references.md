# Interface Pattern References

**Status:** Research and adaptation guidance — for owner review  
**Last updated:** 2026-11-08

This page records external application patterns and earlier Galaxy Game UI research that may inform presentation and interaction. These references are not sources of Galaxy Game domain rules, data structures or gameplay behavior.

## 1. Reference applications and their roles

| Reference | Useful for | Do not import |
|---|---|---|
| EVE Dashboard | Dense dashboard composition, navigation patterns, panels, wayfinding, maps, tables and client-side interactions | EVE terminology, account/corporation concepts, game rules, APIs or branding |
| EVE Tycoon | Organizing market, industry and manufacturing workflows | EVE market semantics, item taxonomy or economic assumptions |
| EVEpraisal | Bulk input, valuation result presentation and summary workflows | EVE price data, valuation rules or service dependencies |
| Main Galaxy Game UI | Actual Galaxy Game terminology, domain concepts and existing workflows | Old visual treatments or admin-only workflows without review |

Galaxy Game's current code, JSON data and established domain documentation remain authoritative for game concepts and behavior.

## 2. EVE Dashboard JavaScript patterns already reviewed

The following existing JavaScript examples have been examined as interaction references. Before creating a new implementation, inspect the current prototype and any first-attempt copies/adaptations to determine whether a useful version already exists.

| Example | Reusable interaction pattern | Galaxy Game adaptation boundary |
|---|---|---|
| `fleet_map.js` | Interactive SVG map, pan/zoom, routes, markers, tooltips, context menus and shortest-path visualization | Reuse map interaction mechanics only. Route meaning, availability and any path calculation must come from Galaxy Game data and rules. |
| `market.js` | Searchable/filterable market table, sorting, summary metrics and refresh interaction | Reuse table/filter patterns. Market data, order semantics, prices and refresh behavior must be supplied by Galaxy Game services. |
| `chain.js` | Interactive network map, node/link editing, zoom/pan and contextual information | Reuse graph interaction patterns. Galaxy Game wormhole topology and edit permissions must come from its own domain rules. |
| `assets.js` | Multi-select filters, select all/none, indeterminate state and typeahead | Reuse generic filter controls. Asset categories and permissions must use Galaxy Game's own data. |
| `wealth.js` | Analytics chart, grouping, filters and transaction drill-down | Reuse analytics presentation. Currency/account semantics and calculations must be backend-authoritative. |
| `structures.js` | Delegated clipboard action and user feedback | Reuse generic clipboard/feedback behavior where useful. |

These are references already identified in prior review, not proof that each file is present in the active prototype. Confirm exact source paths and current copies before implementation.

## 3. Presentation patterns worth evaluating

### Information-dense workspaces
- Clear page title and current scope.
- Compact summary metrics only where they answer a useful question.
- Tables for comparable records and repeated operational data.
- Detail panes or contextual actions for selected records.
- Filters and search close to the data they affect.
- Explicit loading, empty, stale and error states.

### Maps and networks
- Pan/zoom and selection should be predictable.
- Markers, links and selected objects should have distinct states.
- Tooltips should supplement, not replace, accessible labels or detail views.
- Route overlays should distinguish known data from unavailable/unknown data.
- Editing controls must only appear where the current application grants the relevant capability.

### Market and industry
- Keep search, filters, sort state and summary metrics coherent.
- Separate an indicative display from a committed transaction.
- Do not calculate prices, balances, production outcomes or market availability in the browser as authoritative results.
- Drill-down should preserve the user's filter/context where possible.

### Bulk input and valuation
- Make accepted input format visible.
- Validate and report row-level problems.
- Distinguish submitted input from normalized results.
- Show aggregate totals alongside detailed rows.
- Do not imply an external valuation source or live price when the backend has not supplied one.

## 4. Current UI foundation and visual direction

The prototype's dark blue/gray surfaces and cyan accent are a working direction from recent UI work, not a frozen design system. Use the existing token names and actual current CSS as the baseline; do not add a second color system or hard-code a new palette in views.

Earlier first-attempt notes contain several different visual suggestions, including a terminal-green game view, a glassmorphic EVE-inspired treatment and cyan/purple accents. These were exploratory references, not all approved choices. The current working prototype appearance and later owner feedback take precedence.

Do not wholesale-import the first-attempt EVE stylesheet. Select individual patterns and adapt them to the current Tailwind v4/Propshaft asset setup after inspecting the live branch.

## 5. Responsive and accessibility expectations

For each implemented interaction:
- provide keyboard-accessible controls and visible focus;
- do not rely on color alone to communicate status;
- retain readable labels and feedback at narrow viewport widths;
- avoid hover-only information or actions;
- preserve table usability without forcing the entire page to overflow;
- ensure maps and charts have a usable textual/detail alternative;
- respect reduced-motion preferences where animation is introduced.

These are quality expectations for future work, not a claim that the current prototype already satisfies them.

## 6. Related planning pages

- [Interface and workflow direction](interface-and-workflows.md)
- [Data integration and migration](data-integration-and-migration.md)
- [First-attempt reconciliation](first-attempt-reconciliation.md)
- [Prototype roadmap](prototype-roadmap.md)
