# Temporary in-process mock API for the Admin AI Manager prototype.
#
# This keeps fixture data out of controllers and gives the workbench and
# overview a shared, replaceable contract. It is not a live game API, does not
# load world JSON, and does not persist or mutate simulation state.
class MockAiManagerApi
  SYSTEMS = [
    {
      id: "sol",
      name: "Sol",
      description: "Primary-system fixture context",
      focus: "Luna base operations and L1 depot support",
      scope: "NPC operations"
    },
    {
      id: "eden",
      name: "Eden",
      description: "Generated-system fixture context",
      focus: "Survey-led settlement deployment",
      scope: "NPC operations"
    }
  ].freeze

  STATUS_OPTIONS = %w[awaiting_review queued active blocked completed].freeze

  TASKS = [
    {
      id: "TASK-SOL-001", system_id: "sol",
      title: "Maintain Luna oxygen reserve",
      objective: "Maintain the configured 30-day emergency oxygen reserve at Luna Base.",
      category: "Life support", status: "awaiting_review", priority: "critical",
      target: "Luna Base", target_type: "Settlement", target_id: "settlement-luna-base",
      origin: "Standing policy", source: "Maintain a 30-day emergency oxygen reserve",
      rationale: "Projected reserve falls below the configured threshold in 18 days.",
      owner: "NPC Operations", updated: "Illustrative fixture",
      constraints: ["Do not reduce the emergency reserve", "Prefer local production before Earth imports"],
      dependencies: ["Confirm PVE oxygen output", "Check available storage capacity"]
    },
    {
      id: "TASK-SOL-002", system_id: "sol",
      title: "Schedule L1 depot fuel transfer",
      objective: "Keep L1 work craft supplied while preserving the depot maneuvering reserve.",
      category: "Logistics", status: "active", priority: "high",
      target: "L1 Depot", target_type: "Station", target_id: "station-l1-depot",
      origin: "Operational objective", source: "Keep Luna-to-L1 work craft supplied",
      rationale: "The next scheduled transfer window is approaching.",
      owner: "NPC Operations", updated: "Illustrative fixture",
      constraints: ["Preserve depot maneuvering reserve"],
      dependencies: ["Confirm tanker availability"]
    },
    {
      id: "TASK-SOL-003", system_id: "sol",
      title: "Receive Venus atmospheric gas delivery",
      objective: "Receive the Venus skimmer payload when Luna receiving infrastructure is ready.",
      category: "Arrival / offload", status: "blocked", priority: "high",
      target: "Luna Base", target_type: "Settlement", target_id: "settlement-luna-base",
      origin: "Operational objective", source: "Luna Precursor Mission Profile · Venus harvester arrival",
      rationale: "The skimmer's N₂ and CO₂ payload can be offloaded only after the Luna tank farm and required cryogenic storage are ready.",
      owner: "NPC Operations", updated: "Illustrative fixture",
      constraints: ["Tank farm must be ready", "Inflatable tanks must be deployed", "At least 3 tanks required", "Cryogenic tanks required"],
      dependencies: ["task_site_prep_foundation_v2", "task_print_inflatable_tank_shells_v2"],
      procedure: {
        id: "task_venus_harvest_arrival_v2", version: "2.0", type: "arrival_offload",
        craft_type: "venus_harvester_skimmer", transit_days: 400,
        source_gases: ["CO2", "N2"],
        payload: [{ name: "N₂", amount: "30,000", unit: "kg" }, { name: "CO₂", amount: "75,000", unit: "kg" }],
        return_propellant: [{ name: "LOX", amount: "10,000", unit: "kg" }, { name: "Methane remaining", amount: "5,000", unit: "kg" }],
        offload_requirements: ["Tank farm ready", "Inflatable tanks deployed", "Minimum 3 tanks", "Cryogenic tanks required"],
        completion_effects: ["Add N₂ and CO₂ to Luna settlement inventory", "Set venus_n2_delivery_completed", "Open habitat_pressurization gate"]
      }
    },
    {
      id: "TASK-EDEN-001", system_id: "eden",
      title: "Assess settlement site readiness",
      objective: "Establish the planned Eden surface presence only after the candidate site is characterized.",
      category: "Settlement deployment", status: "blocked", priority: "normal",
      target: "Eden Candidate Site A", target_type: "Surface site", target_id: "eden-site-a",
      origin: "Higher-level AI decision", source: "Establish the planned Eden surface presence",
      rationale: "Surface deployment awaits completion of the orbital survey.",
      owner: "NPC Operations", updated: "Illustrative fixture",
      constraints: ["Use the standard settlement deployment package"],
      dependencies: ["Complete orbital survey", "Confirm landing zone"]
    },
    {
      id: "TASK-EDEN-002", system_id: "eden",
      title: "Review orbital support inventory",
      objective: "Complete the scheduled inventory review for the Eden orbital support package.",
      category: "Logistics", status: "completed", priority: "low",
      target: "Eden Orbital Station", target_type: "Station", target_id: "eden-orbital-station",
      origin: "World condition", source: "Inventory reached scheduled review interval",
      rationale: "Routine inventory review completed.",
      owner: "NPC Operations", updated: "Illustrative fixture",
      constraints: [], dependencies: []
    }
  ].freeze

  DECISIONS = [
    {
      id: "DEC-SOL-001", system_id: "sol", task_id: "TASK-SOL-001",
      title: "Review oxygen reserve forecast",
      decision_type: "Reserve review", outcome: "Awaiting operator review",
      source: "Standing policy", authority: "NPC Operations",
      target: "Luna Base", recorded_label: "Illustrative decision",
      reasoning: "The projected reserve crosses its review threshold before the configured 30-day reserve is restored. Verify local PVE output and storage evidence before selecting an external supply path."
    },
    {
      id: "DEC-SOL-002", system_id: "sol", task_id: "TASK-SOL-002",
      title: "Maintain L1 transfer priority",
      decision_type: "Logistics scheduling", outcome: "Active",
      source: "Operational objective", authority: "NPC Operations",
      target: "L1 Depot", recorded_label: "Illustrative decision",
      reasoning: "The next transfer window is approaching. Keep the work-craft supply task active while preserving the depot maneuvering reserve."
    },
    {
      id: "DEC-SOL-003", system_id: "sol", task_id: "TASK-SOL-003",
      title: "Hold Venus cargo offload",
      decision_type: "Arrival / offload gating", outcome: "Blocked",
      source: "Operational objective", authority: "NPC Operations",
      target: "Luna Base", recorded_label: "Illustrative decision",
      reasoning: "Do not offload the current N₂ and CO₂ payload until the tank farm, minimum inflatable tank count, and cryogenic storage prerequisites are ready."
    },
    {
      id: "DEC-EDEN-001", system_id: "eden", task_id: "TASK-EDEN-001",
      title: "Wait for orbital survey evidence",
      decision_type: "Site selection", outcome: "Blocked",
      source: "Higher-level AI decision", authority: "NPC Operations",
      target: "Eden Candidate Site A", recorded_label: "Illustrative decision",
      reasoning: "Keep surface deployment pending until the orbital survey characterizes the candidate landing zone."
    }
  ].freeze

  def systems
    SYSTEMS.deep_dup
  end

  def resolve_system(requested_id)
    systems.any? { |system| system[:id] == requested_id } ? requested_id : SYSTEMS.first[:id]
  end

  def system(id)
    SYSTEMS.find { |record| record[:id] == id }&.deep_dup
  end

  def status_options
    STATUS_OPTIONS
  end

  def status_label(status)
    {
      "awaiting_review" => "Needs attention",
      "queued" => "Queued",
      "active" => "Active",
      "blocked" => "Blocked",
      "completed" => "Completed"
    }.fetch(status.to_s, status.to_s.humanize)
  end

  def tasks(system_id: nil)
    records = system_id.present? ? TASKS.select { |task| task[:system_id] == system_id } : TASKS
    records.map { |task| task.deep_dup.merge(status_label: status_label(task[:status])) }
  end

  def task(id)
    record = TASKS.find { |task| task[:id] == id }
    record&.deep_dup&.merge(status_label: status_label(record[:status]))
  end

  def decisions(system_id: nil)
    records = system_id.present? ? DECISIONS.select { |decision| decision[:system_id] == system_id } : DECISIONS
    records.map(&:deep_dup)
  end

  def overview(system_id:)
    selected_system = resolve_system(system_id)
    selected_tasks = tasks(system_id: selected_system)
    attention_tasks = selected_tasks.select { |task| task[:status] == "awaiting_review" }
    blocked_tasks = selected_tasks.select { |task| task[:status] == "blocked" }

    {
      system: system(selected_system),
      source_label: "Prototype fixtures · not connected to the simulation",
      authority: "NPC Operations",
      counts: {
        attention: attention_tasks.length,
        queued: selected_tasks.count { |task| task[:status] == "queued" },
        active: selected_tasks.count { |task| task[:status] == "active" },
        blocked: blocked_tasks.length,
        completed: selected_tasks.count { |task| task[:status] == "completed" }
      },
      objectives: selected_tasks.reject { |task| task[:status] == "completed" },
      conditions: (attention_tasks + blocked_tasks),
      recent_decisions: decisions(system_id: selected_system).first(4)
    }
  end

  def plan(task)
    if task[:procedure]
      procedure = task[:procedure]
      {
        id: "PLAN-#{task[:id]}", status: "Illustrative · prerequisite blocked",
        summary: "Validate the arrival prerequisites, receive the skimmer, and transfer its harvested gases into Luna inventory. This plan is a UI example derived from the V2 task definition, not a claim that the task currently executes successfully.",
        steps: [
          { title: "Resolve prerequisite tasks", detail: "Confirm site preparation and inflatable tank-shell deployment are complete.", status: "Prerequisite check" },
          { title: "Verify receiving infrastructure", detail: "Confirm tank farm readiness, at least three deployed inflatable tanks, and cryogenic storage.", status: "Prerequisite check" },
          { title: "Receive and inspect skimmer", detail: "Confirm the Venus harvester has arrived at Luna with the expected payload and return propellant.", status: "Pending" },
          { title: "Offload harvested gases", detail: "Transfer 30,000 kg N₂ and 75,000 kg CO₂ to the Luna settlement inventory.", status: "Pending" },
          { title: "Verify completion effects", detail: "Confirm the delivery flag and habitat-pressurization gate are updated.", status: "Pending" }
        ],
        resources: [
          { name: "N₂ payload", quantity: "30,000 kg" },
          { name: "CO₂ payload", quantity: "75,000 kg" },
          { name: "LOX retained for return", quantity: "10,000 kg" },
          { name: "Methane remaining", quantity: "5,000 kg" }
        ],
        alternatives: ["The V2 task definition does not specify alternate offload strategies."],
        procedure: procedure
      }
    else
      {
        id: "PLAN-#{task[:id]}",
        status: task[:status] == "awaiting_review" ? "Proposed" : "Illustrative",
        summary: "A representative plan for reviewing the task and its constraints.",
        steps: [
          { title: "Assess current state", detail: "Read the target's current inventory and operating condition.", status: "Ready" },
          { title: "Evaluate local options", detail: "Check available assets, production, and nearby supply.", status: "Pending" },
          { title: "Prepare action proposal", detail: "Compare cost, schedule, and operational risk.", status: "Pending" }
        ],
        resources: [{ name: "Required resources", quantity: "To be assessed from live state" }],
        alternatives: ["Alternatives are not populated in this fixture."]
      }
    end
  end

  def execution(task)
    {
      id: "EXEC-#{task[:id]}",
      status: task[:status] == "active" ? "In progress (mock)" : "Not started (mock)",
      asset: task[:system_id] == "sol" ? "Luna Operations Group" : "Eden Deployment Group",
      progress: task[:status] == "active" ? 45 : 0,
      events: ["Task created from #{task[:origin].downcase}", "Target resolved: #{task[:target]}"]
    }
  end
end
