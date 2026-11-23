class Admin::AiManagerController < Admin::BaseController
  layout "dashboard"

  def index
    @systems = api.systems
    @selected_system = api.resolve_system(params[:system])
    @overview = api.overview(system_id: @selected_system)
  end

  def missions
    @active_missions = mock_missions[:active]
    @completed_missions = mock_missions[:completed]
    @failed_missions = mock_missions[:failed]
    @pending_missions = mock_missions[:pending]
    @blocked_missions = mock_missions[:blocked]
  end

  def decisions
    @systems = api.systems
    @selected_system = api.resolve_system(params[:system])
    @decisions = api.decisions(system_id: @selected_system)
    @decision_counts = {
      total: @decisions.length,
      awaiting_review: @decisions.count { |decision| decision[:outcome] == "Awaiting operator review" },
      active: @decisions.count { |decision| decision[:outcome] == "Active" },
      blocked: @decisions.count { |decision| decision[:outcome] == "Blocked" }
    }
  end

  def planner
    @patterns = mock_patterns
    @simulation_result = mock_simulation_result
  end

  def patterns
    @patterns = mock_patterns
  end

  def performance
    @metrics = mock_performance_metrics
  end

  def show_mission
    selected = (mock_missions[:active] + mock_missions[:pending] + mock_missions[:blocked] + mock_missions[:completed] + mock_missions[:failed])
      .find { |mission| mission[:identifier] == params[:identifier] } || mock_missions[:active].first

    @mission = mock_mission_detail.merge(
      identifier: selected[:identifier],
      settlement: selected[:settlement],
      status: selected[:status] || "completed",
      progress: selected[:progress] || 100,
      mission_type: selected[:type],
      created_at: selected[:created_at]
    )
    @task_list = mock_task_list
    @current_task_index = if @mission[:status].to_s == "completed"
      @task_list.length
    else
      [((@mission[:progress].to_i / 25) - 1), 0].max.clamp(0, @task_list.length - 1)
    end
    @manifest = @mission[:manifest]
    @mission_activity = mock_mission_activity(@mission[:identifier])
    @mission_results = mock_mission_results(@mission[:identifier], @mission[:status])
  end

  def advance_phase
    # Stub action for prototype — no backend logic
    redirect_to admin_ai_manager_show_mission_path, notice: "Phase advanced (mock)"
  end

  def reset_mission
    # Stub action for prototype — no backend logic
    redirect_to admin_ai_manager_show_mission_path, notice: "Mission reset (mock)"
  end

  private

  def api
    @api ||= MockAiManagerApi.new
  end

  # ── Mock data helpers ──────────────────────────────────────────────

  def mock_missions
    {
      active: [
        { identifier: "MIS-4821", settlement: "Luna Base Alpha", progress: 73, status: "in_progress", type: "resource_extraction", created_at: 5.days.ago },
        { identifier: "MIS-4819", settlement: "Venus Orbital Station", progress: 34, status: "in_progress", type: "infrastructure_build", created_at: 12.days.ago },
        { identifier: "MIS-4815", settlement: "Mars Colony Theta", progress: 91, status: "in_progress", type: "terraforming", created_at: 30.days.ago },
        { identifier: "MIS-4812", settlement: "Ceres Outpost Gamma", progress: 15, status: "delayed", type: "supply_chain", created_at: 45.days.ago }
      ],
      completed: [
        { identifier: "MIS-4798", settlement: "Luna Base Alpha", completion_date: 2.days.ago, created_at: 10.days.ago, type: "construction" },
        { identifier: "MIS-4791", settlement: "Venus Orbital Station", completion_date: 7.days.ago, created_at: 25.days.ago, type: "research" },
        { identifier: "MIS-4785", settlement: "Titan Research Hub", completion_date: 14.days.ago, created_at: 35.days.ago, type: "resource_extraction" },
        { identifier: "MIS-4779", settlement: "Asteroid Belt Depot Kappa", completion_date: 21.days.ago, created_at: 45.days.ago, type: "infrastructure_build" },
        { identifier: "MIS-4770", settlement: "Luna Base Alpha", completion_date: 35.days.ago, created_at: 60.days.ago, type: "supply_chain" }
      ],
      failed: [
        { identifier: "MIS-4802", settlement: "Phobos Transfer Station", status: "failed", type: "construction", reason: "resource_shortage", created_at: 20.days.ago },
        { identifier: "MIS-4795", settlement: "Europa Deep Lab", status: "stalled", type: "research", reason: "equipment_failure", created_at: 30.days.ago }
      ],
      pending: [
        { identifier: "MIS-4808", settlement: "Luna Base Alpha", status: "pending", progress: 0, type: "life_support_expansion", created_at: 1.day.ago }
      ],
      blocked: [
        { identifier: "MIS-4806", settlement: "L1 Depot", status: "blocked", progress: 42, type: "depot_construction", reason: "awaiting_high_tech_imports", created_at: 3.days.ago }
      ]
    }
  end

  def mock_simulation_result
    {
      local_capabilities: { available: true, location: "Luna Base Alpha", atmosphere: ["N2", "CO2", "O2"], surface: ["iron", "titanium", "regolith"] },
      costs: {
        total_gcc: 48_750_000, contingency: 4_875_000, grand_total: 53_625_000,
        precursor_total_savings: 12_400_000,
        breakdown: {
          "iron_ingots" => { source: "Luna Regolith", source_type: "local", quantity: 15_000, unit_cost: 245, total: 3_675_000 },
          "CNT_fibers" => { source: "Venus Atmosphere", source_type: "import", quantity: 500, unit_cost: 8_200, total: 4_100_000 },
          "O2_tanks" => { source: "Luna ISRU", source_type: "local", quantity: 2_000, unit_cost: 180, total: 360_000 },
          "solar_panels" => { source: "Earth Import", source_type: "import", quantity: 800, unit_cost: 12_500, total: 10_000_000 },
          "habitat_modules" => { source: "Luna Manufacturing", source_type: "local", quantity: 45, unit_cost: 95_000, total: 4_275_000 },
          "power_cells" => { source: "Asteroid PGMs", source_type: "import", quantity: 1_200, unit_cost: 3_800, total: 4_560_000 }
        }
      },
      timeline: { total_years: 3.5, phases: [{ name: "Site Preparation", duration: 0.5 }, { name: "Foundation Build", duration: 1.0 }, { name: "Systems Integration", duration: 1.0 }, { name: "Testing & Commissioning", duration: 1.0 }] },
      player_revenue: { total_opportunity_gcc: 8_400_000, contract_count: 23, average_contract_value: 365_000 },
      resources: { peak_demand: { year: 2, total_units: 45_000 }, total: { "iron" => 15_000, "regolith" => 85_000, "O2" => 2_000, "CNTs" => 500, "water" => 12_000 } },
      planetary_changes: { atmosphere: { O2_increase: "+0.3%", N2_stability: "stable" }, surface: { mining_impact: "moderate", regolith_depletion: "12%" } },
      sourcing_strategy: { precursor_recommendation: { payback_analysis: { recommendation: "Invest in precursor infrastructure — 18-month payback" }, estimated_savings: 12_400_000 } }
    }
  end

  def mock_patterns
    [
      { id: "mars-terraforming", name: "Mars Terraforming", target_body: "Mars", description: "Multi-phase atmospheric transformation mission targeting Mars surface conditions", estimated_duration: 15, complexity: "extreme", success_rate: 34, active: true },
      { id: "venus-industrial", name: "Venus Industrial Complex", target_body: "Venus Orbital", description: "High-altitude floating platform for CNT and chemical production", estimated_duration: 4, complexity: "high", success_rate: 78, active: true },
      { id: "titan-fuel", name: "Titan Fuel Mining", target_body: "Titan", description: "Methane extraction and processing facility for cycler fuel supply", estimated_duration: 2.5, complexity: "medium", success_rate: 91, active: true },
      { id: "asteroid-mining", name: "Asteroid Belt Mining", target_body: "Belt Sector 7-G", description: "Automated PGM and metal extraction from designated asteroid cluster", estimated_duration: 3, complexity: "medium", success_rate: 85, active: false },
      { id: "europa-water", name: "Europa Water Extraction", target_body: "Europa", description: "Sub-ice ocean water harvesting for ISRU and settlement support", estimated_duration: 5, complexity: "high", success_rate: 62, active: false },
      { id: "luna-shipyard", name: "Luna Shipyard Construction", target_body: "Luna", description: "Orbital construction platform for cycler and skimmer assembly", estimated_duration: 6, complexity: "high", success_rate: 71, active: true }
    ]
  end

  def mock_performance_metrics
    {
      success_rate: 87.3, average_timeline: "4.2 months", resource_efficiency: 92.1,
      decisions_today: 156, active_missions: 4, total_missions_all_time: 4_821,
      system_uptime: "99.97%", avg_decision_latency_ms: 12, pattern_library_size: 47,
      resource_utilization: { cpu: 34, memory: 67, storage: 45, network: 28 }
    }
  end

  def mock_mission_detail
    {
      identifier: "MIS-4821", settlement: "Luna Base Alpha", status: "in_progress", progress: 73,
      mission_type: "resource_extraction", created_at: 5.days.ago, completion_date: nil,
      manifest: { target_location: { body: "Luna Regolith Fields", coordinates: "12.4N 45.8E" }, mission_objective: "Extract and process 15,000 tons of iron-rich regolith for Mars Colony Theta supply chain. Phase 1 complete — site survey and equipment deployment." },
      operational_data: { current_phase: 3, total_phases: 5, fuel_consumed: "2,400 GCC", labor_hours: 18_500 }
    }
  end

  def mock_mission_activity(identifier)
    completed = identifier == "MIS-4798"
    entries = [
      { time: "08:14:02", kind: "AI MANAGER", message: "Evaluating Luna base construction objectives", tone: "cyan" },
      { time: "08:16:41", kind: "TASK COMPLETE", message: "Regolith site preparation accepted", tone: "success" },
      { time: "08:16:42", kind: "INVENTORY", message: "+12.4 t regolith transferred to construction stockpile", tone: "muted" },
      { time: "08:22:10", kind: "TASK COMPLETE", message: "Oxygen processing unit commissioned", tone: "success" },
      { time: "08:22:11", kind: "VOLATILES", message: "+840 kg LOX recorded in storage", tone: "muted" },
      { time: "08:29:36", kind: "GCC FLOW", message: "125 GCC posted to local production account", tone: "violet" },
      { time: "08:37:05", kind: "ASSET CREATED", message: "Habitat module H-004 commissioned", tone: "success" }
    ]
    entries << { time: "08:41:18", kind: "MISSION COMPLETE", message: "Construction objectives satisfied; final state recorded", tone: "success" } if completed
    entries
  end

  def mock_mission_results(identifier, status)
    return nil unless identifier == "MIS-4798" || status.to_s == "completed"

    {
      assets: [{ name: "Habitat module H-004", detail: "Commissioned" }, { name: "Oxygen processing unit OX-02", detail: "Operational" }, { name: "Regolith handling line RH-01", detail: "Operational" }],
      stockpiles: [{ name: "Regolith", quantity: "12.4 t" }, { name: "Processed construction feedstock", quantity: "3.2 t" }],
      volatiles: [{ name: "LOX", quantity: "840 kg", capacity: "1,200 kg" }, { name: "Water", quantity: "2,150 kg", capacity: "3,000 kg" }, { name: "Hydrogen", quantity: "180 kg", capacity: "500 kg" }],
      gcc: [{ flow: "Local production credit", amount: "+125 GCC" }, { flow: "Construction and commissioning", amount: "-410 GCC" }],
      note: "Illustrative completed-run snapshot. Values are prototype fixtures, not authoritative simulation results."
    }
  end

  def mock_task_list
    [
      { task_id: "T-4821-A", description: "Site survey and geological mapping of extraction zone", type: "survey", resource: "regolith", quantity: nil, craft_type: "orbital_scanner", facility_type: nil, dependencies: [] },
      { task_id: "T-4821-B", description: "Deploy automated mining drones to Sector Alpha-7", type: "deployment", resource: "mining_drone", quantity: 24, craft_type: "lander", facility_type: "drone_hangar", dependencies: ["T-4821-A"] },
      { task_id: "T-4821-C", description: "Establish primary processing plant and O2 separation unit", type: "construction", resource: "processing_equipment", quantity: 8, craft_type: "cargo_lander", facility_type: "ISRU_plant", dependencies: ["T-4821-A"] },
      { task_id: "T-4821-D", description: "Begin bulk extraction and initial refinement operations", type: "extraction", resource: "iron_ingots", quantity: 15_000, craft_type: "cycler", facility_type: nil, dependencies: ["T-4821-B", "T-4821-C"] },
      { task_id: "T-4821-E", description: "Quality control and packaging for transport to Mars", type: "logistics", resource: "iron_ingots", quantity: 15_000, craft_type: "cycler", facility_type: nil, dependencies: ["T-4821-D"] }
    ]
  end
end
