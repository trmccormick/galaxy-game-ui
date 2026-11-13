# Galaxy Game UI Wiki

This wiki documents the **separate Galaxy Game UI application**: its application architecture, interface responsibilities, interaction patterns, migration approach, design decisions, open questions, and evidence from the running prototype.

## Documentation ownership

Keep the three documentation homes distinct:

| Location | Owns |
|---|---|
| This repository's `docs/wiki/` | UI application architecture, player/admin workflows, presentation and interaction design, Rails/API/JavaScript integration, migration planning, prototype evidence |
| `galaxyGame/docs/wiki/` | Game-domain rules, simulation behavior, authoritative mechanics, game data meaning, and established gameplay intent |
| `agent-tasks/projects/galaxy-game-ui/` | Actionable work orders, review items, status, and session handoffs |

The main game's current code and authoritative domain documentation govern game behavior and product design intent. This UI wiki must not create or redefine game mechanics or become a competing product-design authority. The canonical UI intent is in `galaxyGame/docs/wiki/ui/`; the canonical organizational/domain intent is in `galaxyGame/docs/wiki/`. When a UI decision depends on a game rule, resolve it in the main game source/wiki first, then record only the prototype-specific implementation implications here.

## Current prototype purpose and direction

**CURRENT WORKING SCOPE — visual/interaction prototype and API discovery, not a production-functional application**

The immediate purpose of this Rails 8 prototype is to assemble and evaluate the intended GalaxyGame views using existing view JavaScript, renderers, assets, and representative data. It does not need to reproduce the full simulation or be production-functional.

- Get the existing view JavaScript and related components/assets in place first. Reuse and port the main game's Planetary, Surface, and Space work wherever practical; investigate broken behavior rather than replacing it by default.
- For Planetary, use the existing confirmed Earth, Mars, Venus, and Titan data and the existing renderer/data path. For Surface, reuse existing surface data and tileset/image assets. For Space, reuse existing GalaxyGame space code and adapt the EVE Dashboard JavaScript/components (including wealth, fleet, chain, and other useful modules) to GalaxyGame terminology and data.
- Preserve existing JavaScript behavior where possible. Adapt labels, data mappings, configuration, loading, and compatibility only as needed. Do not rewrite working fleet, chain, renderer, or dashboard code merely to fit the prototype.
- Feed imported GalaxyGame JSON or clearly identified mock JSON into the same presentation code. Mock data is acceptable to demonstrate a view or interaction where real data is unavailable; it must not be mistaken for confirmed game behavior.
- Add only the minimum prototype support needed to load data/assets and demonstrate navigation, rendering, selections, and representative interactions. Production API endpoints, full simulation operations, and backend integration are not prerequisites for this design exercise.
- As each view is assembled, record what data it needs, what existing data/code/assets supply it, what is mocked or adapted, and what remains missing. These observations will help define future main-game API requirements; they do not themselves establish API contracts.
- Settlement is the major new Player view. Its detailed design is early exploration; keep candidate layouts and mechanics explicitly provisional.
- The main Rails 7 application remains the authority for game data and mechanics. The Rails 8 prototype is a separate presentation workspace. The eventual API boundary and integration approach remain open until informed by the prototype and reviewed against the main application.

## Current interface principles

The product has two primary dashboards: **Player Dashboard** and **Admin Dashboard**. They are different products for different audiences and workflows; do not reuse Player Dashboard screens as Admin screens or vice versa. The Player Dashboard has exactly four contexts: **Space, Planetary, Surface, and Settlement**. Galaxy/system catalogs and system workspaces are navigation and selection workspaces, not additional Player views. The Admin Dashboard contains dedicated workspaces including **AI Manager** and **Map Studio**, plus simulation, data, account, and system-administration tools. AI Manager is a major operational workspace within Admin, not a fifth Player view.

The immediate prototype priority is to bring forward existing Player-view JavaScript, renderers, data, and assets—Planetary, Surface, and Space—using imported or clearly identified mock JSON. The goal is to get the views demonstrable, not production-functional. Settlement is a new, early-design workspace; Admin and AI Manager screens remain part of the broader prototype scope. Mock actions must not be presented as connected to live simulation services.

The visual direction is dark charcoal/navy with cyan as the primary accent. Green is for success/healthy/operational states rather than the dominant theme; amber and red communicate warnings and errors. Preserve the strongest existing prototype layouts and components, refine typography and information density, and do not revert to the legacy green-on-black appearance.

Use compact catalogs and tables for large collections, then drill down into system assessments and celestial-body analysis. EVE PI Planner is a reference for the list → assessment → detailed analysis interaction pattern, not for Galaxy Game terminology, mechanics, or its Colony model.

Map Studio is an Admin tool within the connected known-world reconstruction / extrasolar generation pipeline feeding the shared planetary Digital Twin. The main game's UI wiki defines the product intent; this repository documents how the prototype represents it.

The main application is also a source of substantial existing view work and domain capability to preserve as reference. Existing screenshot findings include a coarse/blurry Planetary map, partially functioning Earth Surface tiles with Trident reporting 0/12 loaded, and a blank Mars Surface map with JavaScript initialization/tile-loading symptoms. These are observations, not diagnosed root causes; see the main game's authoritative [Current UI State and Known Issues](https://github.com/trmccormick/galaxyGame/blob/main/docs/wiki/ui/04_current_ui_state_and_known_issues.md). The prototype should evaluate useful Planetary, Surface, Map Studio, Monitor, resource, infrastructure, and other specialized experiences for preservation, repair, adaptation, or replacement as appropriate. The old main-app views do not need to be visually repaired if the prototype becomes their replacement presentation. Under the API proposal, the main application would expose the underlying capabilities while the prototype supplies the new UI. The main application remains authoritative for simulation behavior and game data.

## Implementation boundaries

- Keep player-facing workflows distinct from the administrator's operational console.
- Prioritize quick access and discoverability. Do not translate the game-domain hierarchy into a deeply nested global sidebar.
- Use contextual selectors, maps, page content, and feature-specific secondary navigation for relationships such as galaxy → system → celestial body.
- Treat mock, harvested, and live data as distinct; never present placeholder data as live game state.
- The UI presents and invokes permitted operations. It does not own simulation decisions, communications routing, orbital calculations, or game-state authority.

## Current capability direction

[Future UI work and capability notes](future_work.md) is the current consolidated reference for owner-confirmed future UI capabilities, including AI Manager observability, mission/simulation supervision, communications visibility, and player expansion workflows.

That page is newer than several supporting planning documents below. Where older planning language overlaps, use the current capability direction and decisions recorded there; supporting documents provide detail and history, not authority to reverse newer intent.

## Supporting architecture and planning references

### Application and data architecture
- [Data integration and backend migration](data-integration-and-migration.md) — JSON reader, Rails API responsibilities, lookup-service port, and progressive migration.
- [Prototype roadmap](prototype-roadmap.md) — proposed planning stages, decision gates, and task-readiness criteria.

### Interface and interaction design
- [Interface and workflow direction](interface-and-workflows.md) — three-interface responsibilities, contextual navigation, location context, and data age.
- [Screen concepts and low-fidelity wireframes](screen-concepts-and-wireframes.md) — candidate workspaces and text wireframes; proposals, not approved screen specifications.
- [Interface pattern references](interface-pattern-references.md) — EVE and other reference patterns, adaptation boundaries, and accessibility expectations.
- [JavaScript reuse and porting plan](javascript-reuse-and-porting-plan.md) — candidate reusable scripts, module boundaries, and proposed porting sequence.

### Historical reconciliation and project evidence
- [First-attempt reconciliation](first-attempt-reconciliation.md) — what to preserve from the earlier prototype and which assumptions were superseded.
- [Legacy task reconciliation](legacy-task-reconciliation.md) — how earlier task proposals map to the current direction; not a task queue.
- [Visual reference and screenshot plan](visual-reference-and-screenshot-plan.md) — capture standards, current prototype screenshots, and EVE reference observations.

## Visual evidence

- [Current Galaxy Game UI screenshots](assets/screenshots/galaxy-game-ui/README.md) — captured prototype screens. They document what rendered at capture time; they are not proof that every shown behavior is live or complete.
- [EVE Dashboard reference notes](assets/screenshots/eve-dashboard/README.md) — code-derived interaction observations, not Galaxy Game domain authority.

## Working rules

- Inspect the active branch before describing implementation as complete.
- Keep design rationale and durable decisions in this wiki; keep task files short and actionable.
- Treat wireframes, roadmaps, reference patterns, and candidate sequences as proposals unless explicitly marked established.
- Do not dispatch implementation merely because a proposal appears in this wiki.
- Record unresolved questions rather than silently filling them with assumptions.
