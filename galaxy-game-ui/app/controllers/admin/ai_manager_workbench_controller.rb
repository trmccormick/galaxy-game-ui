class Admin::AiManagerWorkbenchController < Admin::BaseController
  layout "dashboard"

  # Prototype-only workbench. Fixtures deliberately bypass world JSON loading;
  # the fixture examples are informed by structures and task definitions in the
  # main GalaxyGame repository. Replace this provider when the UI mock API exists.
  def index
    @systems = mock_systems
    requested_system = params[:system].presence
    @selected_system = mock_systems.any? { |system| system[:id] == requested_system } ? requested_system : "sol"
    @all_tasks = mock_tasks.select { |task| task[:system_id] == @selected_system }

    @filters = {
      status: params[:status].presence,
      category: params[:category].presence,
      query: params[:q].to_s.strip
    }
    @tasks = @all_tasks
    @tasks = @tasks.select { |task| task[:status] == @filters[:status] } if @filters[:status]
    @tasks = @tasks.select { |task| task[:category] == @filters[:category] } if @filters[:category]
    if @filters[:query].present?
      needle = @filters[:query].downcase
      @tasks = @tasks.select do |task|
        [task[:id], task[:title], task[:target], task[:origin], task[:source]].compact.any? { |value| value.downcase.include?(needle) }
      end
    end

    @status_options = @all_tasks.map { |task| task[:status] }.uniq.sort
    @category_options = @all_tasks.map { |task| task[:category] }.uniq.sort
    @counts = {
      attention: @all_tasks.count { |task| %w[blocked awaiting_review].include?(task[:status]) },
      active: @all_tasks.count { |task| task[:status] == "active" },
      completed: @all_tasks.count { |task| task[:status] == "completed" }
    }
  end

  def show
    @task = find_task
    @system = mock_systems.find { |system| system[:id] == @task[:system_id] }
    @plan = mock_plan(@task)
  end

  def plan
    @task = find_task
    @plan = mock_plan(@task)
  end

  def execution
    @task = find_task
    @execution = mock_execution(@task)
  end

  def review
    @task = find_task
    outcome = params[:outcome].to_s
    unless %w[approve reject defer].include?(outcome)
      return redirect_to admin_ai_manager_workbench_plan_path(@task[:id]), alert: "Choose a valid review action."
    end

    redirect_to admin_ai_manager_workbench_task_path(@task[:id]),
      notice: "#{outcome.humanize} recorded for this prototype session only; no game state was changed."
  end

  private

  def find_task
    mock_tasks.find { |task| task[:id] == params[:id] } || raise(ActiveRecord::RecordNotFound)
  end

  def mock_systems
    [
      { id: "sol", name: "Sol", description: "Known-good primary system dataset", status: "Loaded" },
      { id: "eden", name: "Eden", description: "Known-good generated system dataset", status: "Loaded" }
    ]
  end

  def mock_tasks
    [
      {
        id: "TASK-SOL-001", system_id: "sol", title: "Maintain Luna oxygen reserve",
        category: "Life support", status: "awaiting_review", priority: "critical",
        target: "Luna Base", target_type: "Settlement", target_id: "settlement-luna-base",
        origin: "Standing policy", source: "Maintain a 30-day emergency oxygen reserve",
        rationale: "Projected reserve falls below the configured threshold in 18 days.",
        owner: "NPC Operations", updated: "8 minutes ago",
        constraints: ["Do not reduce the emergency reserve", "Prefer local production before Earth imports"],
        dependencies: ["Confirm PVE oxygen output", "Check available storage capacity"]
      },
      {
        id: "TASK-SOL-002", system_id: "sol", title: "Schedule L1 depot fuel transfer",
        category: "Logistics", status: "active", priority: "high",
        target: "L1 Depot", target_type: "Station", target_id: "station-l1-depot",
        origin: "Operational objective", source: "Keep Luna-to-L1 work craft supplied",
        rationale: "The next scheduled transfer window is approaching.",
        owner: "NPC Operations", updated: "21 minutes ago",
        constraints: ["Preserve depot maneuvering reserve"],
        dependencies: ["Confirm tanker availability"]
      },
      {
        id: "TASK-SOL-003", system_id: "sol", title: "Receive Venus atmospheric gas delivery",
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
        id: "TASK-EDEN-001", system_id: "eden", title: "Assess settlement site readiness",
        category: "Settlement deployment", status: "blocked", priority: "normal",
        target: "Eden Candidate Site A", target_type: "Surface site", target_id: "eden-site-a",
        origin: "Higher-level AI decision", source: "Establish the planned Eden surface presence",
        rationale: "Surface deployment awaits completion of the orbital survey.",
        owner: "NPC Operations", updated: "1 hour ago",
        constraints: ["Use the standard settlement deployment package"],
        dependencies: ["Complete orbital survey", "Confirm landing zone"]
      },
      {
        id: "TASK-EDEN-002", system_id: "eden", title: "Review orbital support inventory",
        category: "Logistics", status: "completed", priority: "low",
        target: "Eden Orbital Station", target_type: "Station", target_id: "eden-orbital-station",
        origin: "World condition", source: "Inventory reached scheduled review interval",
        rationale: "Routine inventory review completed.",
        owner: "NPC Operations", updated: "Yesterday",
        constraints: [], dependencies: []
      }
    ]
  end

  def mock_plan(task)
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

  def mock_execution(task)
    {
      id: "EXEC-#{task[:id]}",
      status: task[:status] == "active" ? "In progress (mock)" : "Not started (mock)",
      asset: task[:system_id] == "sol" ? "Luna Operations Group" : "Eden Deployment Group",
      progress: task[:status] == "active" ? 45 : 0,
      events: ["Task created from #{task[:origin].downcase}", "Target resolved: #{task[:target]}"]
    }
  end
end
