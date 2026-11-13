# Future UI Work and Capability Notes

**Status:** Design direction and candidate work, not implementation commitments  
**Last updated:** 2026-11-09

This page records useful future interface capabilities so they can become focused implementation tasks when the prototype is ready. It is not a production architecture specification or a commitment to build every item.

## 1. Immediate priority: AI Manager activity and decision inspector

The first substantial Admin Dashboard experience should make the AI Manager's autonomous work understandable and inspectable. AI Manager is a dedicated workspace within Admin, not a Player Dashboard view.

The interface should help an administrator answer:

- What is the AI Manager doing now?
- What is it trying to accomplish?
- What assets, facilities, missions, or infrastructure is it constructing or deploying?
- Why did it choose this approach?
- Which alternatives or constraints influenced the decision?
- What is complete, in progress, queued, blocked, or awaiting resources?
- What happened after the action was taken?

Candidate UI elements:

- Activity feed with timestamps and status.
- Decision list with selected decision details.
- Decision rationale, relevant constraints, and considered alternatives where available.
- Construction/deployment progress and associated assets.
- Resource, logistics, and dependency summaries.
- Links from an activity or decision to the relevant settlement, station, craft, celestial body, or project.
- Filters by system, location, activity type, status, and time.

The interface should expose the AI Manager's actual reasoning records and operational state when available. It must not fabricate explanations or imply that mock data is live simulation output.

This is an observability and supervisory tool, not a control panel that silently takes authority away from the AI Manager. Pre-player pause, inspection, correction of mission conditions, and resume are part of the intended operator workflow. Directly overriding individual AI decisions or taking over execution remains a separate design question.

### Strategic expansion, wormhole network, and EM economy

AI Manager also directs strategic expansion of the human-operated network. This is not limited to assigning missions: it evaluates when to scout, harvest, stabilize, connect, settle, or move on.

**Natural wormhole monitoring**
- Track each natural wormhole's relative stability; no natural wormhole is permanently or absolutely stable.
- Monitor mass throughput, remaining mass-limit capacity, and changing risk.
- Monitor EM ejected into local space, amount captured/harvested, stored reserves, amount returned for stabilization, and EM expenditure.
- Account for the relationship between mass pushed through and EM ejection: greater throughput produces greater ejection, and an unstable wormhole ejects much more EM.
- When stabilization technology is available, capture ejected EM and direct it back toward the wormhole to restore mass-limit capacity and improve relative stability.

**Hammer Protocol scouting and expansion**
1. Use Sol as the current staging/scouting system to access a candidate system through a natural wormhole.
2. Survey its celestial bodies, harvestable EM field, other resources, and settlement potential.
3. Harvest resources while the natural connection remains open, if worthwhile.
4. Decide whether to continue harvesting, stabilize the natural connection, invest in an AWS pair, establish a settlement, or complete harvesting and hammer the natural exit to force a shift and begin scouting elsewhere.
5. Do not build an AWS pair automatically just because a system was discovered. Network integration is a strategic investment decision.

Systems discovered and surveyed through this process have a harvestable EM field under the current design. Unvisited systems in the local bubble remain unknown; do not assume their EM field or resources are known before discovery.

**Settlement connection strategy**
A system selected for settlement will likely receive an AWS pair connected to Sol while the natural wormhole is still open. This provides an initial logistics corridor for personnel, equipment, construction materials, and supplies. Depending on the design and state of the connection, settlement logistics may use a stabilized natural wormhole or an artificial connection. The network connection may be reconsidered or moved later.

**Sol scenario exception**
For the current human-expansion scenario, Sol's natural wormhole remains present and does not shift or snap; the narrative is also currently planned around its continued existence. It is comparatively more stable because of its placement opposite Jupiter, not absolutely stable. Keep this as a scenario-level rule that can change in future scenarios rather than a permanent limitation on general wormhole simulation.

**AWS placement evaluation**
Candidate placement must consider gravitational/counterbalance geometry, EM stabilization needs, orbital motion, inner-system/habitable-zone avoidance, ship travel time, fuel, construction, resupply, and maintenance. Current Sol planning treats Jupiter as occupied by the natural wormhole and considers Saturn, Uranus, and Neptune or an outer-system balancing pair; exact locations and pairings remain open. Farther-out locations can increase travel and resupply time, but actual transfer times depend on trajectories, orbital positions, propulsion, and launch windows. Planet Nine is hypothetical and is not part of the current baseline.

The AI Manager's goal is not to maximize connected-system count. It should balance expansion capability, resource access, system value, long-term logistics, and the cost/risk of maintaining connections.

## 2. Mission planning, simulation supervision, and AI evaluation

The admin experience should let an operator define **mission objectives**, not author a fixed sequence of construction steps. The main game's AI Manager is responsible for evaluating a location, choosing priorities, planning a path to the objective, allocating resources, and adapting to conditions. The UI should make those decisions observable and reviewable.

Keep strategic selection separate from execution: the `missions_v2` / `tasks` layer describes how a selected deployment or activity is performed. It does not decide whether that activity is appropriate, where it is needed, when it should happen, or how it ranks against other needs. The AI Manager makes those decisions from the world state and mission objectives, then invokes suitable mission/task procedures to execute the chosen work. The interface should make both the strategic decision and the selected execution procedure visible without confusing one for the other.

During development, Rake tasks are used as mission profiles to test candidate settlement approaches. They are examples and validated options available to inform the AI Manager, not exhaustive choices or fixed deployment scripts. The intended AI Manager should evaluate a location's properties and the mission objective, then draft a suitable cargo manifest and deployment plan—choosing the equipment, supplies, materials, spares, and quantities that make sense for that situation. It may adapt or combine tested approaches, or choose another approach when the available profiles do not fit. The admin UI should expose the resulting manifest and the decisions behind it, rather than imply that the operator selected a predetermined profile for literal replay.

### Mission setup

Candidate mission inputs include:
- Desired outcome (for example, establish a usable Luna lava-tube foothold).
- Target world / location and starting conditions.
- Available equipment, resources, and funding.
- Constraints, safety requirements, and required capabilities.
- Optional milestones or evaluation criteria.

Do not make the operator specify every harvest, processing run, print job, construction step, or deployment order. Those are part of the AI Manager's planning and execution responsibilities. Existing settlement patterns and prior missions may inform the plan, but should not be presented as fixed scripts; the AI Manager must adapt its approach to the target location and current conditions.

### Run, inspect, intervene, and resume

The admin interface should support the pre-player buildout workflow:

1. Assign a mission and let the AI Manager plan and execute it.
2. Observe at a selected simulation speed, or accelerate through routine activity.
3. Pause at a checkpoint or when a problem is detected.
4. Inspect progress, inventories (including stored volatiles), resource consumption, construction results, equipment condition, maintenance, failures, unexpected events, and the AI Manager's decisions and responses.
5. Correct conditions or mission inputs, then resume and evaluate the result.

Accelerated simulation and manual buildout time jumps must still execute all intervening simulation activity and consequences. The UI must not imply that time jumps skip work or merely alter the displayed date. Pause and manual time jumps are pre-player operator controls; individual players do not control the shared universe clock or its rate.

### Evaluation and training records

The inspector should help compare the AI Manager's chosen path with the mission objective and actual outcome. Useful records include the initial conditions, objective and constraints, decisions and rationale where available, alternatives considered where genuinely recorded, task/activity history, resource use, blockers, failures, recovery actions, and final results.

The purpose is to evaluate whether the AI Manager can independently discover and execute a good settlement path—not whether it can replay a developer-authored script. Do not fabricate reasoning or training data that the game does not actually provide; distinguish live records, harvested records, and mock prototype data.

### Player expansion after AI-established access

The UI should also eventually support the player-facing consequences of the settlement model:
- Players and player corporations can establish their own bases and settlements once a world is accessible.
- Players / corporations may lease suitable space at NPC settlements for portal endpoints or pairs, subject to the game's portal constraints.
- Portal connections can support convenient movement of eligible payloads and imports / exports; do not present portals as unrestricted bulk-freight replacements.
- NPC settlements continue providing services and may expand capacity while player-owned operations grow alongside them.

The game wiki is authoritative for settlement rules, portal constraints, simulation behavior, and economic mechanics. The UI should present those capabilities without inventing additional rules.

## 3. Communications and network visibility

The communications interface should make delayed command delivery understandable without implying faster-than-light messaging.

The main game's communications design is authoritative. See [Interstellar Communications](https://github.com/trmccormick/galaxyGame/blob/main/docs/wiki/engineering/interstellar_communications.md).

### Player-facing communications

A player should be able to understand:

- Whether a command or message has been sent.
- Its expected route and delivery time.
- Whether it is waiting for an electromagnetic link, relay, or physical carrier.
- Whether it has reached the target.
- Whether the target has executed the command.
- Whether confirmation has returned to the sender.

Keep three milestones distinct:

1. **Command arrival** at the target.
2. **Execution** by the target (which may occur later).
3. **Acknowledgment arrival** back at the origin.

The origin should not be shown as fully confirmed merely because a command was handed to a carrier or delivered to its destination.

### Route visualization

A route view may show:

- Active radio/laser links and powered relay nodes.
- Store-and-forward queues and handoffs.
- Ships, shuttles, robots, or other physical carriers transporting packet copies.
- Portal crossings, where a traveler or device physically carries data between connected locations.
- Natural wormhole or AWS crossings used by physical carriers between systems.
- Estimated and actual arrival times, delays, and route changes.

Suggested visual distinctions, subject to prototype testing:

- Cyan: electromagnetic transmission.
- Amber: conventional physical carrier.
- Violet: portal-carried transfer.
- Green: completed delivery or acknowledgment.

These colors are suggestions, not locked design tokens. Preserve the existing dark/cyan GalaxyGame identity and use color alongside labels, icons, or line styles so meaning is not color-only.

### Administrator network inspector

An administrator may need a more detailed view of:

- Route selection and available alternatives.
- Relay/node availability and capability.
- Carrier schedules, destinations, and handoff points.
- Queue/capacity constraints and environmental impacts.
- Estimated versus actual delivery and acknowledgment times.
- Route changes and the reason for a reroute.

The routing service remains authoritative. The UI visualizes the route and status it receives; it does not calculate authoritative routes or create a separate orbital model. Existing orbital simulation data should supply relevant positions and movement predictions.

### Scope guardrails

- No faster-than-light electromagnetic messaging.
- Portals and wormholes are physical transport shortcuts for carriers, not interchangeable communication technologies.
- Do not assume that a portal or wormhole aperture directly transmits a data signal.
- Do not build a sophisticated independent network simulator in the UI.
- Route history may be useful for diagnostics, but the UI should not require permanent storage of every possible route.
- Use mock data for early layout and interaction work; label it clearly.

## 4. Candidate implementation sequence

These are suggested work packages, not fixed milestones. Reorder them as prototype learning and available game data dictate.

| Order | Candidate task | Intended outcome |
|---|---|---|
| 1 | AI Manager Activity & Decision Inspector | Admin can see current activity, decisions, rationale, progress, and blockers. |
| 2 | Communications Status & Timeline | Show message/command lifecycle and separate arrival, execution, and acknowledgment. |
| 3 | Communications Route Visualization | Show RF links, relays, physical carriers, portal crossings, and wormhole/AWS carrier routes. |
| 4 | Admin Network Inspector | Expose routing choices, node/carrier availability, constraints, and timing diagnostics. |
| 5 | Player Communications Workspace | Present a focused player-facing view of messages and remote-command status. |

Tasks should remain narrow and independently testable. Start with static or mock data where that lets the interface be evaluated before backend integration is available.

## 5. Prototype and integration boundaries

- Reuse existing prototype components and useful code from the main game where practical; adapt or replace them when the prototype shows a better approach.
- Favor working screens and realistic interaction over premature framework or service design.
- Clearly label mock, sample, harvested, and live data.
- Identify the information each screen needs, but do not prescribe Rails models, database migrations, jobs, or API contracts here.
- When backend integration becomes relevant, derive the required data from the main game's actual services and models.
- Admin and player views may share data and components while exposing different detail and permissions.

## 6. Open questions

- Which AI Manager decision records and activity states are already available to the UI?
- Which parts of the communications route and lifecycle will the game expose first?
- How much route detail belongs in the player workspace versus the admin inspector?
- Which map and route interactions from the Python dashboard reference are worth adapting?
- Which status colors and line styles remain legible across the prototype's map and panel backgrounds?

Resolve these through prototype use and inspection of the actual game data, rather than treating this page as a source of predetermined answers.
