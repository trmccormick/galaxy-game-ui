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

## Current application direction

- The prototype is intended to become the foundation of the new Galaxy Game interface, not remain a disconnected visual mockup.
- JavaScript is the primary presentation and interaction layer.
- The main GalaxyGame application exposes the authoritative API; this separate prototype UI consumes it.
- The main application retains game state, domain services, calculations, validation, persistence, authorization, and operations.
- Reuse the main application's existing lookup/data-access behavior behind deliberate API contracts; do not duplicate its reader or game logic in the prototype.
- Mock or local JSON data may support visual design, but it must remain clearly separate from live API data and must not be treated as an API contract.
- Progressively port or integrate existing game models and services in small, tested vertical slices. Preserve behavior before refactoring.
- The final application boundary, framework choices beyond the current Rails/Hotwire foundation, API contracts, and migration sequence remain open unless explicitly decided.

## Current interface principles

The product has three distinct interfaces: **Main Game / Player**, **Admin**, and **AI Manager**. They share a visual language but serve different audiences and workflows. The Player interface's five views (Planetary, Surface, Settlement, Space, Galaxy) are a separate layer of organization; do not confuse the three application interfaces with those five player views.

The current prototype priority is Admin and AI Manager before Player. Mock data and JSON-backed screens are acceptable while the workflows and presentation are developed. Do not imply that mock actions are connected to live simulation services.

The visual direction is dark charcoal/navy with cyan as the primary accent. Green is for success/healthy/operational states rather than the dominant theme; amber and red communicate warnings and errors. Preserve the strongest existing prototype layouts and components, refine typography and information density, and do not revert to the legacy green-on-black appearance.

Use compact catalogs and tables for large collections, then drill down into system assessments and celestial-body analysis. EVE PI Planner is a reference for the list → assessment → detailed analysis interaction pattern, not for Galaxy Game terminology, mechanics, or its Colony model.

Map Studio is an Admin tool within the connected known-world reconstruction / extrasolar generation pipeline feeding the shared planetary Digital Twin. The main game's UI wiki defines the product intent; this repository documents how the prototype represents it.

The main application is also a source of substantial existing view work to preserve and improve. Review and port useful Planetary/Orbital, Surface, Map Studio, Monitor, resource, infrastructure, and other specialized views. They are incomplete and inconsistent in places, not disposable. Establish the prototype's consistent presentation first; later evaluate backporting the refined views or consuming main-app capabilities through an API. The main application remains authoritative for simulation behavior and game data.

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
