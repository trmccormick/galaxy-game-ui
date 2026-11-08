# Galaxy Game UI

The Galaxy Game UI repository is the separate application and interface-development workspace for the new Galaxy Game experience.

The project is evolving from a visual prototype into the foundation of the new interface:

- **JavaScript** is the primary presentation and interaction layer.
- **Rails** provides the application backend and API, including authentication, game-data access, validation, domain services, persistence, and authoritative game behavior.
- **Galaxy Game JSON data** is initially read through a reader built in this application, exposed through Rails API resources, and consumed by the JavaScript interface.
- Existing Galaxy Game models and services will be progressively ported or integrated as small, tested slices. Preserve existing behavior before refactoring.

This repository's project wiki records the architecture, interface direction, decisions, open questions, and migration approach.

## Project documentation

- [Project wiki](docs/wiki/README.md) — project direction, architecture and current baseline.
- [Interface and workflows](docs/wiki/interface-and-workflows.md) — player/admin responsibilities, navigation and contextual UI.
- [Data integration and migration](docs/wiki/data-integration-and-migration.md) — JSON reader, Rails API, JavaScript and progressive backend migration.
- [First-attempt reconciliation](docs/wiki/first-attempt-reconciliation.md) — reusable work and superseded assumptions.
- [Legacy task reconciliation](docs/wiki/legacy-task-reconciliation.md) — how older task proposals map to the current plan.
- [Interface pattern references](docs/wiki/interface-pattern-references.md) — reusable presentation and JavaScript patterns.
- [Prototype roadmap](docs/wiki/prototype-roadmap.md) — proposed planning stages before implementation tasks.

## Related repositories

- `galaxyGame` — main game application, game-domain code, JSON data, and domain wiki.
- `agent-tasks` — actionable implementation tasks, review queue, status notes, and session handoffs.

The project wiki explains which repository owns which kind of information. Do not treat placeholder data or mock fixtures as authoritative game data.

## Current status

The UI foundation is under active development. The final navigation, page structure, visual design, frontend framework choices beyond the existing Rails/Hotwire foundation, API resource contracts, and exact backend migration sequence remain open unless recorded as decided in the project wiki.
