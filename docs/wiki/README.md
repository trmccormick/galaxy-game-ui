# Galaxy Game UI Wiki

This wiki documents the **separate Galaxy Game UI application**: its application architecture, interface responsibilities, interaction patterns, migration approach, design decisions, open questions, and evidence from the running prototype.

## Documentation ownership

Keep the three documentation homes distinct:

| Location | Owns |
|---|---|
| This repository's `docs/wiki/` | UI application architecture, player/admin workflows, presentation and interaction design, Rails/API/JavaScript integration, migration planning, prototype evidence |
| `galaxyGame/docs/wiki/` | Game-domain rules, simulation behavior, authoritative mechanics, game data meaning, and established gameplay intent |
| `agent-tasks/projects/galaxy-game-ui/` | Actionable work orders, review items, status, and session handoffs |

The main game's current code and authoritative domain documentation govern game behavior. This UI wiki must not create or redefine game mechanics. When a UI decision depends on a game rule, resolve the domain question in the main game source first, then document the resulting interface decision here.

## Current application direction

- The prototype is intended to become the foundation of the new Galaxy Game interface, not remain a disconnected visual mockup.
- JavaScript is the primary presentation and interaction layer.
- Rails provides the application backend/API, authentication and authorization, game-data access, validation, domain services, persistence, and authoritative behavior.
- Begin integration with a controlled JSON reader adapted from the main game's lookup behavior, exposed through application-level API resources.
- Progressively port or integrate existing game models and services in small, tested vertical slices. Preserve behavior before refactoring.
- The final application boundary, framework choices beyond the current Rails/Hotwire foundation, API contracts, and migration sequence remain open unless explicitly decided.

## Current interface principles

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
- [Interface and workflow direction](interface-and-workflows.md) — player/admin responsibilities, contextual navigation, location context, and data age.
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
