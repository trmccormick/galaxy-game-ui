# Galaxy Game UI

This repository is the separate application and interface-development workspace for the new Galaxy Game experience.

The project is evolving from a visual prototype into the foundation of the new interface:

- **JavaScript** is the primary presentation and interaction layer.
- **This prototype uses Rails 8.x** as its UI application framework.
- **The existing main GalaxyGame application uses Rails 7.x.**
- **Proposed, not yet adopted:** the main Rails 7 application would expose the game API, and this Rails 8 prototype would consume it. The main application would retain authoritative game state, domain services, validation, persistence, and simulation behavior; the prototype would focus on presentation and interaction.
- The two applications would run separately during integrated development. A one-command startup setup and one PostgreSQL server with separate logical databases are options to evaluate; the prototype must not directly access the main application's game tables.
- Mock data may continue to support screen development, clearly separated from live API data. API endpoints, process orchestration, and database arrangements remain to be designed and approved.

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
