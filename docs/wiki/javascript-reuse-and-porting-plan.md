# JavaScript Reuse, Porting, and Module Plan

**Status:** Proposed technical direction — for owner review  
**Last updated:** 2026-11-08

This page records the reuse-first direction for bringing existing GalaxyGame view JavaScript and EVE Dashboard presentation/interaction code into the Rails 8 prototype. It is a porting plan, not authorization to begin implementation. The prototype's immediate goal is to demonstrate views with imported or mock JSON and help identify future API data requirements—not to build a production-functional application.

## 1. Guiding approach

- Recover and inspect any JavaScript already copied or adapted into galaxy-game-ui before creating a second implementation.
- First inspect and reuse the actual main-game view JavaScript, renderers, data-loading paths, and image assets. Planetary, Surface, and Space are port/adaptation targets, not blank-page redesigns.
- Use confirmed existing Planetary data for Earth, Mars, Venus, and Titan; reuse existing Surface data and tileset images.
- Reuse EVE Dashboard JavaScript such as wealth, fleet, chain, map, assets, market, and other useful modules as appropriate. Adapt GalaxyGame terminology and data mappings while preserving working behavior. EVE terminology and game rules are not imported.
- Do not rewrite fleet, chain, renderer, or dashboard modules merely to fit the prototype. Add small adapters, configuration, or compatibility support only where needed.
- Imported GalaxyGame JSON and clearly identified mock JSON should feed the same view code. The prototype only needs enough behavior to demonstrate the intended screens and representative interactions.
- Separate reusable presentation behavior from GalaxyGame-specific data mapping. Record data needs and gaps as evidence for later API design; do not treat prototype fixtures as API contracts.
- Keep authoritative state and game rules in the main application. Do not build production API operations or duplicate simulation logic in the prototype as part of this exercise.
- Work within the existing Rails/Importmap/Stimulus foundation unless inspection shows a concrete need to change it; do not introduce a new build system or dependency merely because a source module used one.

## Completion Status (2026-11-08)

| Step | Description | Status |
|------|-------------|--------|
| Step 0 — Recover/audit existing JS copies | Inspected current branch; no EVE JS copies found in active prototype | ✅ Completed |
| Steps 1–8 — Porting sequence | Not yet started (implementation) | ⏳ Pending |

**Previous prototype audit finding (2026-11-08):** No EVE-derived JavaScript files were found copied or adapted into the active `galaxy-game-ui` prototype at that time. The six known reference modules (`fleet_map.js`, `market.js`, `chain.js`, `assets.js`, `wealth.js`, `structures.js`) had been examined in earlier work, but their original source location/revision was not recorded in this repository. This is not an instruction to rebuild them from scratch. Recover the original source or the previously supplied files, inspect current prototype copies and dependencies, then adapt the useful modules to GalaxyGame terminology and data. Reconfirm this audit against the current branch before implementation.

**Screenshot evidence:** Current UI screenshots are available at `docs/wiki/assets/screenshots/galaxy-game-ui/`. These show the actual rendered pages where adapted EVE patterns would eventually be integrated (dashboard tables, navigation panels, admin console).

---

## 1A. Original EVE Dashboard source location

The original EVE Dashboard application is a separate local Python project under:

`/Users/tam0013/Documents/git/eve-dashboard/`

The JavaScript modules were previously supplied/reviewed from that project. They are not part of the GalaxyGame main repository. Recover the original modules from this local source before adapting them; do not recreate them from descriptions or copy EVE application backend behavior. Known modules include `fleet_map.js`, `market.js`, `chain.js`, `assets.js`, `wealth.js`, and `structures.js`.

## 2. Reference-file inventory

The following files were reviewed in earlier sessions and are the known reference set.

| Reference file | Existing pattern | Evidence | Reuse assessment | Galaxy Game adaptation |
|---|---|---|---|---|
| fleet_map.js | SVG map, pan/zoom, markers, routes, tooltips, context menus, shortest-path interaction | REPORTED (code-derived from previously examined JS file) | **Adapt selectively** | Map canvas and interaction controller for star-system/spatial views. Replace EVE objects, route semantics, data contracts, and actions with Galaxy Game concepts. |
| market.js | Searchable/filterable table, sorting, summary metrics, refresh | REPORTED (code-derived from previously examined JS file) | **Strong candidate to adapt** | Generic table/search/filter/sort pattern for market and other data-heavy workspaces. Keep market-specific columns and transaction behavior separate. |
| chain.js | Interactive network graph, editing, pan/zoom, links, contextual details | REPORTED (code-derived from previously examined JS file) | **Adapt selectively** | Possible infrastructure/logistics/network visualization. Do not assume EVE chain topology maps directly to Galaxy Game networks. |
| assets.js | Multi-select filters, select all/none, indeterminate state, typeahead | REPORTED (code-derived from previously examined JS file) | **Strong candidate to adapt** | Reusable filter/selection controller for assets, inventories, and other bulk-selection interfaces. |
| wealth.js | Analytics chart, grouping, filters, shared selection, transaction drill-down | REPORTED (code-derived from previously examined JS file) | **Adapt selectively** | Possible economy/finance analytics after authoritative transaction and history data are available. |
| structures.js | Delegated clipboard actions and feedback | REPORTED (code-derived from previously examined JS file) | **Small reusable pattern** | Shared clipboard utility/controller for identifiers, coordinates, or other copyable values. |

The table identifies patterns, not verified current prototype file paths. Exact source locations, licensing/provenance, dependencies, and whether copies already exist must be checked in the current repository before a task is drafted.

## 3. Port, adapt, or create

### A. Port/adapt from the shown references

#### Map interaction — fleet_map.js

Potentially reusable:
- SVG or canvas interaction structure, depending on the actual reference implementation;
- pan and zoom;
- marker selection and hover details;
- layer/filter toggles;
- selected-object information panel;
- keyboard/mouse interaction patterns.

Must be redesigned:
- Galaxy Game object types and hierarchy;
- coordinates, scale, and map projection;
- route and travel semantics;
- object visibility and access rules;
- action menus and backend endpoints;
- empty/loading/error behavior.

**Candidate destination:** a focused map controller/module plus a Galaxy Game map data adapter. Exact filenames are OPEN.

#### Data-table interaction — market.js

Potentially reusable:
- local filtering and sorting of an already-authorized result set;
- search input behavior;
- selected-row state;
- summary/header refresh pattern;
- separation between table presentation and data retrieval.

Must be redesigned:
- API response mapping;
- columns and formatting;
- pagination/large-result handling;
- market-specific price/offer/transaction semantics;
- server-side filtering if result volume requires it.

**Candidate destination:** shared table/filter behavior with feature-specific market configuration. Do not turn one large market module into a generic framework prematurely.

#### Multi-select and typeahead — assets.js

Potentially reusable:
- select-all/select-none behavior;
- indeterminate checkbox state;
- multiselect filter state;
- typeahead/search interaction;
- accessible keyboard behavior, if present and verified.

**Candidate destination:** a small reusable selection/filter controller used by asset and other list screens.

#### Network visualization — chain.js

Potentially reusable:
- graph pan/zoom;
- node and edge selection;
- contextual details;
- editing interaction patterns where appropriate.

Must be redesigned:
- graph meaning and topology;
- permitted node/edge operations;
- authoritative graph data and validation;
- whether editing belongs in the player interface at all.

**Candidate use:** a later infrastructure/logistics relationship view, only if a real Galaxy Game workflow requires it.

#### Analytics — wealth.js

Potentially reusable:
- chart grouping and filter interactions;
- linked chart/table selection;
- drill-down interaction;
- updating a chart from selected filters.

Must be redesigned:
- metrics and units;
- aggregation rules;
- time windows and data freshness;
- financial meaning and permissions.

**Candidate use:** economy or operations analytics after backend data contracts exist. Not a first-slice dependency.

#### Clipboard — structures.js

Potentially reusable:
- delegated click handling;
- copying a value;
- success/failure feedback;
- avoiding one handler per repeated control.

**Candidate use:** shared utility/controller, low complexity and potentially useful across many screens.

### B. Create specifically for Galaxy Game

| Proposed module responsibility | Why it is new |
|---|---|
| Application navigation/context | Must distinguish current player location, selected object, and query scope. |
| API client/request conventions | Must establish consistent Rails API requests, errors, credentials, and response handling. |
| Galaxy Game data adapters | Must map actual API resources into view-specific display models without inventing game rules. |
| Celestial-body layer/workspace controller | Must coordinate Monitor, Planetary, Surface, and selected inspection context. |
| Player workspace orchestration | Must manage page-level state and shared context without making a fixed dashboard the architecture. |
| Admin-specific interaction modules | Must respect the separate admin audience, routes, and permissions. |
| Notifications/status presentation | Must represent authoritative operation results and data freshness. |

These are responsibility areas, not a required list of files. Split modules only when current implementation and tests justify it.

## 4. Proposed JavaScript organization

**DIRECTION:** Start from the existing Rails JavaScript entry point, Importmap, and Stimulus. Prefer feature-focused controllers/modules over a large global script. Exact directory layout is OPEN pending inspection of current code and any recovered EVE adaptations.

Illustrative organization:

```text
app/javascript/
  application.js
  controllers/
    application_context_controller.js
    map_controller.js
    data_table_controller.js
    multi_select_controller.js
    celestial_body_controller.js
    clipboard_controller.js
  services/
    api_client.js
  adapters/
    galaxy_map_adapter.js
    market_data_adapter.js
    asset_data_adapter.js
  features/
    map/
    assets/
    market/
    celestial_body/
```

This is illustrative. Avoid creating empty folders or generic abstractions before there are two or more real consumers. A behavior can begin as a small Stimulus controller and be extracted only when reuse is demonstrated.

### Module boundaries

- **Controller:** binds browser interactions to a screen or component.
- **Presentation helper:** formatting and small DOM/presentation operations.
- **API client:** request conventions, credentials, parsing, and consistent error handling.
- **Adapter:** translates a known API response into the shape required by a view.
- **Backend service:** authoritative lookup, validation, calculations, permissions, and durable changes.

A frontend adapter must not duplicate authoritative game rules. It may format or organize values for display.

## 5. Integration with Rails and Stimulus

The inspected prototype foundation uses Importmap, Turbo, and Stimulus. Unless the current branch has changed, a reasonable starting pattern is:

1. Rails renders the page shell and data attributes needed to identify the feature/context.
2. Stimulus connects the relevant controller to the DOM.
3. The controller requests data through a small API client or feature-specific request method.
4. A feature adapter maps the API response to display-ready values.
5. The controller updates the relevant view region and presents loading, empty, and error states.
6. Any state-changing action is submitted to Rails, where authentication, authorization, validation, and persistence are enforced.
7. The UI reflects the confirmed backend result; it does not claim success before the response.

Do not choose React, Vue, or another framework as a prerequisite. Revisit the frontend framework only if concrete workflow complexity demonstrates that the current foundation is insufficient.

## 6. Suggested porting sequence

This is a dependency-aware proposal, not an approved implementation schedule.

| Sequence | Candidate | Reason | Prerequisites |
|---|---|---|---|
| 0 | Recover/audit existing JS copies and adaptations | Avoid duplicate work and preserve prior useful code | Current branch and local work available for inspection |
| 1 | API client/request convention | Needed for all API-backed features | Agree first API slice and auth/CSRF behavior |
| 2 | Small data-table/filter pattern | Broad utility; relatively easy to verify | One real list endpoint/workflow |
| 3 | Multi-select/typeahead behavior | Useful reusable interaction | Confirm list-screen use case and accessibility |
| 4 | Clipboard feedback pattern | Small shared utility | Confirm current browser support and existing code |
| 5 | Map interaction | High-value but more domain-dependent | Real map data, scale/coordinate semantics, selected-object contract |
| 6 | Celestial-body layer controller | Central Galaxy Game inspection workflow | Reconcile main game's Monitor/Planetary/Surface behavior |
| 7 | Network visualization | Specialized | Confirm infrastructure/logistics workflow and graph meaning |
| 8 | Analytics/drill-down | Specialized | Real metrics, aggregation, and history API contracts |

The first vertical slice may change this order. The chosen workflow, not this table, determines what should be ported first.

## 7. Porting checklist

For each reference file:
- [ ] Locate the original file and record its repository/source and revision.
- [ ] Search the current prototype and local working tree for copies, partial ports, or related controllers.
- [ ] Identify dependencies, global variables, selectors, CSS assumptions, endpoints, and data shapes.
- [ ] Separate generic interaction behavior from EVE-specific domain logic.
- [ ] Identify accessibility, keyboard, touch, and responsive behavior.
- [ ] Map required data and actions to real Galaxy Game domain/API sources.
- [ ] Remove EVE-specific names, assumptions, and endpoints from the adapted implementation.
- [ ] Add tests for pure behavior and controller interactions where practical.
- [ ] Verify in the running application at desktop and relevant narrow widths.
- [ ] Record what was reused, rewritten, omitted, and why.

Do not copy a reference file and rename its functions as a substitute for this review.

## 8. API and state boundaries

JavaScript may own:
- current selected row/marker/tab;
- open/closed panels and menus;
- temporary filter/search input;
- map viewport and visual layer selection;
- transient loading indicators;
- optimistic presentation only where rollback and server confirmation are handled correctly.

Rails/backend must own:
- permissions and access checks;
- game rules and calculations;
- resource availability and inventory truth;
- transaction and market outcomes;
- research/manufacturing validity and progress;
- movement, location, and operational state;
- durable player/admin changes.

The API contract should provide enough information for the screen to explain what happened, including validation failures and unavailable actions. The frontend should not infer permission from the presence of a button or from a hidden control.

## 9. Open questions

- Where are the original EVE reference files stored, and what exact revisions were shown?
- Which of these files have already been copied or partially adapted into the current prototype?
- Do any reference files depend on libraries or global page structures not present in the prototype?
- Which first workflow best exercises the API/JavaScript boundary?
- Should shared behaviors be Stimulus controllers, plain ES modules, or a combination? Initial direction: use existing Stimulus foundation and extract plain modules for reusable logic.
- What map rendering approach best fits actual Galaxy Game spatial data and expected scale?
- Which interactions need server-side search/filtering rather than client-side filtering?
- What update cadence is required for each screen?

## 10. Relationship to future tasks

A task that ports a reference should link to this page and name:
- the exact reference file and source revision;
- the exact current prototype file(s) inspected;
- the interaction behavior in scope;
- EVE-specific behavior to remove;
- Galaxy Game API/domain dependencies;
- tests and rendered verification required.

A task should not simply say "port fleet_map.js" or "port market.js." It must define the specific Galaxy Game workflow and behavior to preserve. This wiki remains the roadmap and design rationale; agent-tasks should contain only the bounded execution request.
