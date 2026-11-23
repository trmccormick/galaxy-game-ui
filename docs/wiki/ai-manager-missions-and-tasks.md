# AI Manager Missions and Task Library

**Status:** Owner-confirmed prototype direction — 2026-11-23  
**Scope:** Admin and Player AI Manager mission/task workflows in the separate UI prototype.

## Core distinction

**Tasks are the individual capabilities and operations designed and maintained in the shared task library. Missions are repeatable operational flows assembled from tasks to accomplish a larger objective, such as establishing or expanding a settlement.** A mission is not merely a single task and should not be reduced to a rigid checklist.

The AI Manager uses a mission as reusable operational guidance. It selects, sequences, combines, and adapts available tasks to current conditions, dependencies, resource availability, assets, and mission constraints. Over time, it should learn from outcomes and eventually help develop or refine mission flows. Current `missions_v2` definitions are experimental examples; the prototype must not imply that they are production-ready or successfully executing.

## Ownership and permissions

### Admin: shared operational library

Admins manage both shared building blocks and predefined repeatable flows:

- **Task Library:** create, inspect, revise, validate, and test task definitions.
- **Mission Library:** create, inspect, revise, validate, and test predefined missions that AI Managers can use.
- **Mission composition:** show how a mission's objective, task references, dependencies, sequence/parallel opportunities, prerequisites, expected outputs, constraints, and completion conditions fit together.
- **Validation and evidence:** review task compatibility, missing dependencies, expected effects, and observed results. Keep experimental or unvalidated content visibly distinguished.

Admin screens are for shared game/NPC operational capability management, not player-specific asset deployment.

### Player: personal missions

Players manage only missions they create for their own operations. A player mission expresses the objective and the guidance the player wants their AI Manager to follow. It can specify:

- objective and desired outcome;
- target settlement, location, or operational scope;
- preferred repeatable operating pattern;
- player constraints, priorities, budget/resource limits, and risk preferences;
- eligible assets or asset groups, where appropriate;
- conditions for repeating, pausing, or requesting player review.

Players do **not** author or maintain the shared task library. They do not need to manually script every task. Their AI Manager plans and deploys the player's assets within the player's authority, using shared tasks and available mission capabilities, and adapts execution as conditions change.

## Prototype screen plan

### Admin / AI Manager

1. **Task Library** — searchable/filterable catalog; task identity, capability/category, requirements, dependencies, expected effects, maturity/validation status, and detail view.
2. **Task Detail / Editor** — inspect and prototype editing of task purpose, parameters, preconditions, dependencies, outputs/effects, and validation notes.
3. **Mission Library** — predefined mission catalog; objective, scope, maturity, linked task count, repeatability, and validation status.
4. **Mission Detail / Designer** — objective and intended outcome; operational flow visualization; linked tasks and dependencies; sequential/concurrent opportunities; resource/asset requirements; repeat/recovery rules; expected outputs and validation evidence.
5. **Mission Validation** — identify unresolved task references, dependency gaps, incompatible requirements, and unverified outcomes. Prototype-only until connected to real validators.
6. **Task Workbench / Execution** — retain as a separate operational inspection experience. It shows task planning/execution evidence, not the mission library itself.

### Player

1. **My Missions** — player-owned mission catalog, status, target/scope, assigned assets, and recent outcomes.
2. **Mission Detail** — objective, guidance, constraints, selected assets, AI Manager's current interpretation/proposal, progress, and results.
3. **Mission Designer** — create/edit personal mission guidance without exposing shared task-definition editing.
4. **Asset Deployment Review** — show which player-owned assets the AI Manager proposes or has assigned, why they fit, and any resource/dependency issues.
5. **Mission Results** — repeat-run history, outcome, deviations/adaptations, and lessons the player may use to refine their guidance.

## Prototype examples and source boundaries

- The main game defines the JSON data root and mission subpaths in `galaxy_game/config/initializers/game_data_paths.rb`. The UI prototype mirrors the relevant `GalaxyGame::Paths` constants and mounts the main `data/json-data/` tree read-only for local testing.
- The two V2 locations are intentionally distinct: `data/json-data/missions_v2/` contains the limited Luna mission/task examples assembled for the testing setup; `data/json-data/missions/tasks_v2/` contains the broader reusable task library in draft form. The prototype should use both through the matching path constants and label their source/maturity accurately.
- The Venus arrival/offload task example belongs to the V2 test/setup task data. It describes a Venus harvester arrival/offload task with N₂/CO₂ payload and Luna tank-farm prerequisites. It is a **task**, not the entire repeatable Venus harvesting mission.
- The main game also contains `precursor_mission_profile_v1.json`, an experimental phase-oriented profile example that references the Venus arrival task. Treat examples as source material only; do not claim the current V2 engine discovers or executes them successfully.
- The Venus Atmospheric Harvest Run shown in prototype mission screens is a representative repeatable mission concept: dispatch/operate the Venus harvester, harvest atmospheric cargo, return to the receiving settlement, offload into prepared storage, and repeat as conditions and launch opportunities permit. The actual detailed task composition and run logic remain subject to main-game code and design validation.
- The prototype may use fixture data to demonstrate screens and interactions. Clearly label fixtures and mock actions; do not change simulation state or claim live execution.

## Navigation boundary

Admin AI Manager navigation exposes **Task Library**, **Mission Library**, and operational workbench/oversight. Player navigation exposes **My Missions** and the player's AI Manager/deployment experience. Do not expose shared task authoring to players.

## Open design questions for review

- How much of a mission's repeat/recovery policy belongs in mission guidance versus AI Manager planning?
- Which mission fields are common across all mission types, and which are mission-specific parameters?
- How should the UI show parallel work, optional branches, and condition-based task selection without turning missions into brittle scripts?
- What validation maturity states are needed for shared tasks and missions?
- Which asset-selection and deployment decisions require explicit player approval versus delegated authority?

These questions are for prototype review; do not prematurely define a backend schema or production execution contract.
