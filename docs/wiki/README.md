# Galaxy Game UI Wiki

This wiki documents the **interface prototype**: its interaction patterns, presentation responsibilities, prototype conventions, and future UI work.

It is intentionally separate from the main `galaxyGame` wiki:

- **Main game wiki** defines game rules, simulation behavior, authoritative domain concepts, and established design intent.
- **This UI wiki** defines how those systems should be presented, inspected, and operated through the interface.

When the two appear to conflict, the main game's current code and authoritative game documentation define the underlying behavior. The UI wiki must not invent or duplicate game mechanics.

## Current prototype direction

- Treat the application as an experimental design prototype, not a production UI architecture.
- Reuse and adapt useful components, assets, JavaScript, CSS, and interaction patterns from the main game and the Python dashboard reference.
- Preserve GalaxyGame's dark, technical visual identity and cyan primary accent; use secondary status colors only where they improve comprehension.
- Prefer contextual navigation, selectors, tabs, and focused detail panels over deeply nested global navigation.
- Use mock or harvested data where useful, and clearly distinguish simulated presentation data from live game data.
- Prioritize an administrator-facing view of AI Manager activity and decisions. Player-facing views can be stubbed where they share useful components or information.

## UI design and future work

- [Future UI work and capability notes](future_work.md) — candidate admin and player interface capabilities, including AI Manager observability and communications/network visibility.

## Authority boundary

The UI is a presentation and interaction layer. It does not own simulation decisions, communications routing, orbital calculations, or game-state authority. Those responsibilities remain with the main game.

