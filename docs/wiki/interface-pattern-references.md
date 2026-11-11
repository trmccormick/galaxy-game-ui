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

| Example | Reusable interaction pattern | Evidence | Galaxy Game adaptation boundary |
|---|---|---|---|
| `fleet_map.js` | Interactive SVG map, pan/zoom, routes, markers, tooltips, context menus and shortest-path visualization | REPORTED (code-derived from previously examined JS file) | Reuse map interaction mechanics only. Route meaning, availability and any path calculation must come from Galaxy Game data and rules. |
| `market.js` | Searchable/filterable market table, sorting, summary metrics and refresh interaction | REPORTED (code-derived from previously examined JS file) | Reuse table/filter patterns. Market data, order semantics, prices and refresh behavior must be supplied by Galaxy Game services. |
| `chain.js` | Interactive network map, node/link editing, zoom/pan and contextual information | REPORTED (code-derived from previously examined JS file) | Reuse graph interaction patterns. Galaxy Game wormhole topology and edit permissions must come from its own domain rules. |
| `assets.js` | Multi-select filters, select all/none, indeterminate state and typeahead | REPORTED (code-derived from previously examined JS file) | Reuse generic filter controls. Asset categories and permissions must use Galaxy Game's own data. |
| `wealth.js` | Analytics chart, grouping, filters and transaction drill-down | REPORTED (code-derived from previously examined JS file) | Reuse analytics presentation. Currency/account semantics and calculations must be backend-authoritative. |
| `structures.js` | Delegated clipboard action and user feedback | REPORTED (code-derived from previously examined JS file) | Reuse generic clipboard/feedback behavior where useful. |

These are references already identified in prior review, not proof that each file is present in the active prototype. Confirm exact source paths and current copies before implementation.

## 3. Presentation patterns worth evaluating

### Catalogs, assessment, and drill-down

A useful pattern for browsing a large universe is a compact system catalog, followed by a selected system assessment, then detailed analysis of a selected celestial body. Prefer tables/lists for comparable records, with contextual selection and drill-down. Deeper analysis can include comparisons, configurable assumptions, and detail panels. EVE PI Planner is a reference for this interaction pattern only; Galaxy Game's domain concepts remain authoritative.

### Match layout to the task

Do not use a dashboard, card grid, or map by default. Choose the presentation that best serves the work: dense table for comparison, map for spatial relationships, detail pane for selected-object inspection, chart for trends, and focused operational workspace for actions.

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

**ESTABLISHED VISUAL DIRECTION — 2026-11-11**

The shared application direction is dark charcoal/navy surfaces with cyan as the primary accent. Continue and refine the prototype's existing dark blue/gray + cyan work; do not restart the visual design or introduce a second palette.

- Green is reserved primarily for success, healthy, and operational status; it should not dominate the overall interface.
- Amber communicates warnings; red communicates errors or critical conditions.
- Use readable, appropriately compact typography and clear spacing between labels, values, descriptions, and actions. Avoid oversized text and crowded text runs.
- Preserve strong existing prototype layouts and components. The main game is a reference for existing functionality and useful visualizations, not automatically the visual standard.
- Keep the space-background image prominent on the landing page where it supports the identity. Do not add large atmospheric backgrounds to operational screens where they reduce readability.

Use the existing token names and actual current CSS as the baseline; do not add a second color system or hard-code a new palette in views.

**Screenshot evidence:** Actual rendered pages are captured at [galaxy-game-ui/README.md](assets/screenshots/galaxy-game-ui/README.md). Key findings:
- Landing page, sign-in, dashboard, and admin console all render with the dark blue/gray + cyan theme.
- The About page is **unstyled** — plain text with no Tailwind or custom CSS applied. This is a verified gap.
- Tailwind CSS asset fails to load (404 on `/assets/tailwindcss`) but Propshaft serves compiled CSS correctly.

Earlier first-attempt notes contain several different visual suggestions, including a terminal-green game view, a glassmorphic EVE-inspired treatment and cyan/purple accents. These were exploratory references, not all approved choices. The current working prototype appearance and later owner feedback take precedence.

Do not wholesale-import the first-attempt EVE stylesheet. Select individual patterns and adapt them to the current Tailwind v4/Propshaft asset setup after inspecting the live branch.

## 5. Combining the reference sources

Evaluate three sources for different strengths:

1. **Main Galaxy Game application:** existing functionality, simulation concepts, domain meaning, and useful working visualizations.
2. **Galaxy Game UI prototype:** stronger visual design, newer layouts, dashboards, navigation, and usability improvements.
3. **EVE and other external references:** useful information architecture and interaction patterns, not their game mechanics, terminology, or branding.

Do not assume one source is the standard for every screen. Preserve the strongest relevant elements from each and adapt them to Galaxy Game's actual workflows.

## 6. Responsive and accessibility expectations

For each implemented interaction:
- provide keyboard-accessible controls and visible focus;
- do not rely on color alone to communicate status;
- retain readable labels and feedback at narrow viewport widths;
- avoid hover-only information or actions;
- preserve table usability without forcing the entire page to overflow;
- ensure maps and charts have a usable textual/detail alternative;
- respect reduced-motion preferences where animation is introduced.

These are quality expectations for future work, not a claim that the current prototype already satisfies them.

## 7. Related planning pages

- [Interface and workflow direction](interface-and-workflows.md)
- [Data integration and migration](data-integration-and-migration.md)
- [First-attempt reconciliation](first-attempt-reconciliation.md)
- [Prototype roadmap](prototype-roadmap.md)

## 8. Main-application views as a porting source

**ESTABLISHED REVIEW PRINCIPLE — 2026-11-11**

The main Galaxy Game application is a source of existing functional capability and specialized view setups, not merely a source of old styling. Its work is substantial but incomplete and inconsistent. The prototype should preserve, complete, and standardize useful work rather than replace it with generic screens.

Review the existing Planetary/Orbital, Surface, Map Studio, Monitor, resource, infrastructure, and other world-inspection/operational views. Confirm their actual implementation and runtime status before describing them as working. For each, identify:

- useful information architecture, domain context, visualizations, controls, and interactions to retain;
- behavior that is incomplete, broken, or not yet verified;
- presentation and usability improvements to make in the prototype;
- data and service dependencies that should remain authoritative in the main application.

A Planetary workspace, Orbital view, Surface workspace, and Map Studio have different purposes. Consistency means coherent navigation, typography, spacing, controls, terminology, and status presentation—not identical page layouts or a universal dashboard template.

## 9. UI-first integration choice

The prototype should first establish and review the look, layout, navigation, and interaction patterns. Mock data may support this work but must not be mistaken for live state or a committed data contract.

When the presentation is ready to integrate, evaluate whether to backport the refined views into the main application or retain the prototype as a separate UI consuming capabilities exposed by a main-application API. This remains an open implementation choice. In either case, the main application owns authoritative simulation behavior, domain rules, calculations, permissions, and operations. Reuse existing services and data access wherever possible; do not recreate game logic in the UI.
