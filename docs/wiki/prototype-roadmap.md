# UI Prototype Roadmap

**Status:** Active — porting existing views incrementally; broad source inventory remains ongoing  
**Last updated:** 2026-11-23

This roadmap governs the GalaxyGame UI prototype. The prototype is a UI and workflow shell: it establishes screens, layouts, navigation, and interactions before the production JSON loader and API integration are ready. It is not a second implementation of the GalaxyGame backend.

Work proceeds in small, reviewable parts. Complete and review one part before moving to the next.

## 1. Governing principles

- **Build on existing work.** Do not assume a screen, workflow, component, or interaction is missing until the relevant sources have been inspected.
- **Port existing views and workflows first.** The main GalaxyGame application may contain useful views even when their data/API wiring is incomplete. Missing wiring is not evidence that a workflow is missing.
- **Reuse the current prototype.** Inspect its existing views, layouts, styles, routes, controllers, JavaScript, fixtures, and assets before adding or replacing anything.
- **Recover useful earlier work.** Review the first UI attempt, earlier prototypes, screenshots, and experiments for reusable implementation or design ideas. Reconcile rather than blindly copy.
- **Use external references as references.** EVE Dashboard (Pixel Nexus Dashboard) and other examples can inform information density, panels, maps, navigation, and interaction patterns. They do not define GalaxyGame mechanics or override its design.
- **Use the Wiki and prior decisions for intent.** Check current GalaxyGame Wiki pages and relevant historical documentation/discussions. Code establishes what is implemented; current Wiki/design decisions establish intended behavior. Record conflicts instead of silently choosing.
- **Mock data is acceptable.** Use clearly identified fixtures/mock responses where the JSON loader or API is not ready. Make views realistic enough to review.
- **Keep data replaceable.** Separate fixture data from presentation so a future JSON/API provider can replace it without rebuilding the screens.
- **Make prototype interactions meaningful.** Navigation, tabs, filters, detail links, forms, and mock actions should work within the prototype where practical. Clearly label mock actions and never imply they change live game state.
- **Adapt presentation, not purpose.** Apply the prototype's visual language—dark/cyan styling, compact typography, legible spacing, and consistent panels—while preserving each existing screen's purpose, information, and workflow.
- **Design genuinely new screens only after reconciliation.** New views should address demonstrated gaps, not duplicate something already present in main, the prototype, or recoverable earlier work.
- **Verify before committing.** Check routes/helpers, links, controller actions, rendering assumptions, and available tests/runtime checks. State clearly when verification is source-only.

## 2. Sources to reconcile

These are distinct sources of evidence, not a simple list of three interfaces:

### GalaxyGame implementation and design
1. Main GalaxyGame repository: Rails views, layouts, controllers, routes, helpers, JavaScript, CSS, assets, and existing data structures.
2. Current GalaxyGame Wiki: authoritative design intent and architecture.
3. Older/frozen documentation and migration history: historical decisions and details to harvest, with conflicts identified.
4. Agent-tasks repository: task drafts, review records, handoffs, and unresolved questions. A historical task is not automatically current authorization.
5. Prior design discussions and confirmed owner decisions that may not yet have been fully documented.

### UI implementation history
6. Current `galaxy-game-ui` repository: existing prototype views, routes, controllers, layouts, components, styles, JavaScript, fixtures, and assets.
7. Earlier UI attempt/repository: recoverable views, scripts, assets, layouts, and design experiments.
8. Prior screenshots, mockups, wireframes, and visual experiments, including catalog, blueprint, and navigation work.

### External references
9. EVE Dashboard / Pixel Nexus Dashboard (one project/reference): inspect its JavaScript and useful patterns for panels, maps, navigation, data density, and interactions.
10. Other identified products and examples, such as EVE Tycoon Market and go-evepraisal, for relevant market/appraisal workflows.
11. Other dashboard/layout references, including Wealth and Mail, where their patterns solve a concrete presentation problem.
12. Genre/interface references such as EVE, SimEarth, Civilization, and SimCity for appropriate player-view conventions.

### Domain and data evidence
13. Existing blueprints, unit definitions, JSON data, lookup services, and data relationships in GalaxyGame.
14. Existing missions, tasks, AI Manager capabilities, operational records, and player workflows.
15. Established Admin, AI Manager, and Player responsibilities, including Planetary, Surface, and Settlement views.

Do not double-count Pixel Nexus Dashboard and EVE Dashboard; they refer to the same reference application.

## 3. Work sequence — one part at a time

### Part 1 — Reconcile sources and inventory existing UI
**Next work item.**

- Inspect the main GalaxyGame routes, controllers, layouts, views, helpers, JavaScript, styles, and relevant data/fixtures.
- Inventory the current UI prototype's corresponding files and working navigation.
- Compare earlier UI attempt material and existing screenshots/mockups.
- Review the relevant Wiki pages and confirmed design decisions.
- Review the EVE Dashboard / Pixel Nexus reference and other examples already identified; record which patterns are useful to which GalaxyGame workflows.
- Build a screen/workflow matrix with source, current location, purpose, implementation status, wiring status, reusable pieces, and gaps.
- Classify items as implemented, partially implemented, disconnected, mock-only, outdated/conflicting, or genuinely absent.
- Do not create new screens during this inventory unless a small inspection aid is necessary.

**Exit condition:** a source-grounded inventory showing what already exists and what is actually missing. No claim of completeness until each source category has been checked.

### Part 2 — Port and reconcile existing views
- Prioritize existing useful main-app views/workflows that are not yet represented in the prototype.
- Port their purpose, information, and workflow; do not require backend/API wiring first.
- Reuse existing prototype layouts, components, styles, and JavaScript where possible.
- Add or adapt fixture data and mock responses for missing data providers.
- Add prototype routes/controller actions needed to navigate and inspect the views.
- Record source and mock-data limitations.
- Avoid parallel replacement screens when an existing implementation can be adapted.

**Exit condition:** selected existing workflows are navigable and reviewable in the prototype, with their behavior and data limitations clearly represented.

### Part 3 — Polish the shared presentation system
- Reconcile typography, spacing, density, panel treatment, navigation, responsive behavior, and visual hierarchy.
- Use the prototype's established dark/cyan visual language.
- Borrow external reference patterns only where they improve a specific GalaxyGame task.
- Improve readability; avoid oversized text and crowded/touching content.
- Keep reusable components consistent without forcing every interface into one layout.

**Exit condition:** ported views look and behave as members of the same GalaxyGame prototype.

### Part 4 — Fill verified gaps with new views
- Revisit the inventory after porting.
- Identify workflows that have no adequate existing view or recoverable implementation.
- Confirm purpose and audience from Wiki/decisions.
- Design one missing workflow at a time, using established layouts and relevant reference patterns.
- Label speculative concepts and unresolved decisions.

**Exit condition:** each new screen addresses a documented gap and does not duplicate existing work.

### Part 5 — Prepare for JSON/API integration
- Keep mock data behind replaceable providers/adapters.
- Confirm the main GalaxyGame API and JSON-loader responsibilities before wiring.
- Replace fixtures incrementally, workflow by workflow.
- Preserve screen structure where possible as data sources change.
- Add loading, empty, error, stale-data, retry, and authorization states as appropriate.
- Never treat local read-only data mounts as the production integration boundary.

**Exit condition:** a narrow, verified integration slice replaces the relevant mock provider without requiring a UI rebuild.

## Current incremental progress

The user has directed that view construction continue in small pieces without requiring phone-based testing. Build on source inspection and fixture data; defer runtime/browser review until a desktop review is practical.

### Map Studio
- **Overview:** added to the prototype with fixture-backed metrics, source collections, recent activity, and the distinction between initial terrain generation and ongoing Digital Twin simulation.
- **Generate Terrain:** ported the existing main-app generation workflow into a compact prototype workspace. It includes target-world selection, map naming and brief, starting-world reference profiles, FreeCiv/Civilization IV source selection, complexity, biome focus, additional instructions, and a configuration preview.
- **Data boundary:** all targets and source maps on the Generate view are illustrative fixtures. The preview is client-side only; it does not generate files, write map data, or alter celestial bodies.
- **Source reconciliation note:** the main-app Generate view has inconsistencies with its controller (for example, target parameter naming/requiredness and source-map fields). The prototype uses a coherent required target selection and explicit fixture records rather than copying those broken bindings.
- **Browse Generated Maps:** inspected and adapted the main-app library workflow into a fixture-backed prototype. Includes search, sorting, biome/complexity/applied-status filters, map cards, metadata inspection modal, and empty/reset state. The main-app Apply action is deliberately not exposed as a live mutation; its current implementation writes terrain into a celestial body's Digital Twin. The prototype labels this integration boundary clearly.
- **Analyze generated map:** ported the legacy inspection workflow into a fixture-backed artifact analysis page. It presents grid dimensions, tile count, biome composition, source references, and the stored fixture quality score. The preview art is explicitly illustrative, not a rendering of map data. The legacy controller's resource-balance, strategic-feature, and overall-playability outputs are placeholders; the prototype calls this out and does not portray them as validated analysis. Applying remains a separate, unconnected write to the body's Geosphere `terrain_map`.
- **Next contained view:** inspect and adapt the select-celestial-body/apply workflow as a safe prototype review/confirmation flow, retaining the distinction between generated artifact and applied body terrain and performing no live writes.

## 4. Current prototype work and existing implementation

The prototype already contains Admin AI Manager and Player mission work. These must be included in the inventory and improved in place where appropriate; do not rebuild them from scratch.

Known existing prototype areas include:
- Admin dashboard and Admin AI Manager overview.
- AI Manager mission views, decisions, planner, patterns, and performance views.
- AI Manager library and workbench views, including task detail, plan, execution, and review.
- Player planetary view and Player mission index/form/detail views.
- Shared dashboard/application layouts and branding.

Some views use fixtures and may be incomplete or disconnected. Their presence and purpose still count as existing work.

The Admin AI Manager workflow already has mock overview, task/workbench, plan review, execution/activity, and decision-log work. Existing mission monitor/history views also contain illustrative fixture data. Inspect current main before deciding whether to retain, reconcile, or replace overlapping pieces.

## 5. Data and backend boundary

- The prototype exists to establish the UI and user workflows before the JSON loader is ready.
- Mock data is a normal temporary development technique, not a reason to postpone a screen.
- Keep fixture data explicit and separate from presentation.
- Do not duplicate a maintained GalaxyGame system-data catalog in the UI repository.
- Production integration should use the agreed main GalaxyGame API/data boundary.
- Local read-only mounts, if present, are for development/source inspection only.
- Mock approve/reject/dispatch controls must not mutate live simulation state or dispatch real assets.
- Do not implement backend/gameplay behavior in the prototype merely to make a mock screen appear functional.

## 6. Interface audiences and design references

Maintain the distinction between:
- **Admin:** supervises/configures/diagnoses shared game operations and tools.
- **AI Manager:** plans, coordinates, and reviews NPC operations; player AI uses the same capabilities under player objectives and delegated authority.
- **Player:** interacts with owned assets, missions, and the game world through player-facing views.

The Player celestial views include:
- **Planetary:** high-level world view.
- **Surface:** settlements, mines, and moving units.
- **Settlement:** detailed local/terrain/colony management view.

These are distinct workflows and should not be collapsed into a generic dashboard.

EVE Dashboard / Pixel Nexus is a reference for presentation and interaction patterns, not a source of GalaxyGame requirements. Other examples should be evaluated against a concrete screen/workflow need rather than added to the design simply because they exist.

## 7. Verification and progress tracking

For each small part, record:
- What source files and reference material were inspected.
- What was already present and reused.
- What was ported, adapted, or newly created.
- Which data is fixture/mock versus live.
- Routes, links, and interactions checked.
- Tests/runtime/browser checks actually performed.
- Known gaps, conflicts, and next small step.

Do not claim runtime or browser verification when only source inspection was possible. Verify route helpers after route changes. Check navigation links against real routes/actions before committing.

Only create a formal agent task for substantial, cross-cutting work that benefits from independent review or dependency tracking. Ordinary view porting and styling refinements can be handled directly in the UI repository. Keep task drafts separate from approval and execution.

## 8. Current next step

**Start Part 1 only:** reconcile the existing main-app UI, current prototype, earlier UI attempt, Wiki/decisions, and reference material into a screen/workflow inventory. Then review that inventory and select one contained porting item for Part 2.

Do not start another broad screen-design exercise or begin JSON/API integration before this inventory and the first porting decisions are reviewed.
