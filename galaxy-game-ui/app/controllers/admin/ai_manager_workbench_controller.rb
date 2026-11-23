class Admin::AiManagerWorkbenchController < Admin::BaseController
  layout "dashboard"

  # Prototype-only workbench. These fixtures deliberately bypass the world JSON
  # loader; replace the fixture provider when the mock API is introduced.
  def index
    @systems = mock_systems
    @selected_system = params[:system].presence || "sol"
    @tasks = mock_tasks.select { |task| task[:system_id] == @selected_system }
    @counts = {
      attention: @tasks.count { |task| %w[blocked awaiting_review].include?(task[:status]) },
      active: @tasks.count { |task| task[:status] == "active" },
      completed: @tasks.count { |task| task[:status] == "completed" }
    }
  end

  def show
    @task = mock_tasks.find { |task| task[:id] == params[:id] }
    raise ActiveRecord::RecordNotFound unless @task
    @system = mock_systems.find { |system| system[:id] == @task[:system_id] }
    @plan = mock_plan(@task)
  end

  def plan
    @task = mock_tasks.find { |task| task[:id] == params[:id] }
    raise ActiveRecord::RecordNotFound unless @task
    @plan = mock_plan(@task)
  end

  def execution
    @task = mock_tasks.find { |task| task[:id] == params[:id] }
    raise ActiveRecord::RecordNotFound unless @task
    @execution = mock_execution(@task)
  end

  def review
    @task = mock_tasks.find { |task| task[:id] == params[:id] }
    raise ActiveRecord::RecordNotFound unless @task
    outcome = params[:outcome].to_s
    unless %w[approve reject defer].include?(outcome)
      return redirect_to admin_ai_manager_workbench_plan_path(@task[:id]), alert: "Choose a valid review action."
    end

    redirect_to admin_ai_manager_workbench_task_path(@task[:id]),
      notice: "#{outcome.humanize} recorded for this prototype session only; no game state was changed."
  end

  private

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
    {
      id: "PLAN-#{task[:id]}",
      status: task[:status] == "awaiting_review" ? "Proposed" : "Illustrative",
      summary: "A representative plan for reviewing the task and its constraints.",
      steps: [
        { title: "Assess current state", detail: "Read the target's current inventory and operating condition.", status: "Ready" },
        { title: "Evaluate local options", detail: "Check available assets, production, and nearby supply.", status: "Pending" },
        { title: "Prepare action proposal", detail: "Compare cost, schedule, and operational risk.", status: "Pending" }
      ],
      resources: [{ name: "Oxygen", quantity: "Illustrative requirement" }, { name: "Available transport capacity", quantity: "To be assessed" }],
      alternatives: ["Use local production and storage", "Request a resupply if local capacity is insufficient"]
    }
  end

  def mock_execution(task)
    {
      id: "EXEC-#{task[:id]}", status: task[:status] == "active" ? "In progress (mock)" : "Not started (mock)",
      asset: task[:system_id] == "sol" ? "Luna Operations Group" : "Eden Deployment Group",
      progress: task[:status] == "active" ? 45 : 0,
      events: ["Task created from #{task[:origin].downcase}", "Target resolved: #{task[:target]}"]
    }
  end
end
