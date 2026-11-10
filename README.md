# Galaxy Game UI

This repository is the separate application and interface-development workspace for the new Galaxy Game experience.

The project is evolving from a visual prototype into the foundation of the new interface:

- **JavaScript** is the primary presentation and interaction layer.
- **Rails** provides the application backend and API, including authentication, game-data access, validation, domain services, persistence, and authoritative game behavior.
- **Galaxy Game JSON data** is initially read through a reader built in this application, exposed through Rails API resources, and consumed by the JavaScript interface.
- Existing Galaxy Game models and services will be progressively ported or integrated as small, tested slices. Preserve existing behavior before refactoring.

## Project documentation

Start with the [UI project wiki](docs/wiki/README.md). It explains documentation ownership, current application direction, and links to the supporting architecture, interface, migration, planning, and evidence pages.

The [Future UI Work and Capability Notes](docs/wiki/future_work.md) records the current consolidated capability direction, including AI Manager observability, mission/simulation supervision, communications visibility, and player expansion workflows.

## Documentation ownership

- `galaxyGame` — main game application, game-domain code, JSON data, and authoritative domain wiki.
- This repository — UI application architecture, interface design, presentation behavior, and integration/migration planning.
- `agent-tasks` — actionable implementation tasks, review queue, status notes, and session handoffs.

The main game's current code and authoritative domain documentation define game rules and behavior. This repository's wiki defines how the UI should present and interact with those capabilities. Do not treat placeholder data or mock fixtures as authoritative game data.

## Current status

The UI foundation is under active development. Final navigation, page structure, visual design, API resource contracts, and exact backend migration sequence remain open unless recorded as decided in the project wiki.
