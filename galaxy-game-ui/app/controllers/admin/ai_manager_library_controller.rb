class Admin::AiManagerLibraryController < Admin::BaseController
  layout "dashboard"

  # Display-only fixtures for the shared task and mission libraries.
  # The V2 source definitions in the main game are experimental examples,
  # not evidence that this prototype is connected to a live execution engine.
  def tasks
    @tasks = task_fixtures
  end

  def task
    @task = task_fixtures.find { |item| item[:id] == params[:id] }
    raise ActiveRecord::RecordNotFound unless @task
  end

  def edit_task
    @task = task_fixtures.find { |item| item[:id] == params[:id] }
    raise ActiveRecord::RecordNotFound unless @task
    raise ActiveRecord::RecordNotFound unless @task[:document]

    @task_json = JSON.pretty_generate(@task[:document])
  end

  def missions
    @missions = mission_fixtures
  end

  def mission
    @mission = mission_fixtures.find { |item| item[:id] == params[:id] }
    raise ActiveRecord::RecordNotFound unless @mission

    @linked_tasks = @mission[:tasks]
  end

  private

  def task_fixtures
    [
      {
        id: "task_venus_harvest_arrival_v2",
        name: "Venus Atmospheric Harvester Arrival at Luna",
        category: "Arrival / offload",
        capability: "Receive and offload harvested atmospheric cargo",
        dependencies: ["Luna tank-farm preparation", "Inflatable tank deployment", "Cryogenic receiving capacity"],
        maturity: "Experimental V2 example",
        source: "Main game: missions_v2/tasks/task_venus_harvest_arrival_v2.json",
        notes: "The task represents the receiving/offload operation. It does not define the entire repeatable Venus harvesting mission.",
        document: {"task_id":"venus_harvest_arrival_v2","version":"2.0","name":"Venus Atmospheric Harvester Arrival at Luna","description":"Venus skimmer arrives at Luna with harvested N₂ + CO₂ payload. Offload requires tank farm infrastructure to be ready.","prerequisites":["task_site_prep_foundation_v2","task_print_inflatable_tank_shells_v2"],"launch_window":{"departure_body":"EARTH-01","arrival_body":"LUNA-01","transit_days":400,"synodic_period_days":584,"note":"Venus skimmer departs Earth around same time as precursor launch. Harvests Venus atmosphere en route."},"payload":{"source_gases":["CO2","N2"],"co2_kg":75000,"n2_kg":30000,"lox_for_return_kg":10000,"methane_remaining_kg":5000},"offload_requirements":{"tank_farm_ready":true,"inflatable_tanks_deployed":true,"minimum_tank_count":3,"cryo_tanks_required":true},"effects":[{"action":"add_to_inventory","target":"luna_settlement","items":[{"name":"N2","amount":30000,"unit":"kg"},{"name":"CO2","amount":75000,"unit":"kg"}]},{"action":"set_status_flag","flag":"venus_n2_delivery_completed","value":true},{"action":"gate_open","target":"habitat_pressurization","description":"N₂ available for habitat pressurization"}],"metadata":{"template":"task_v2","type":"arrival_offload","craft_type":"venus_harvester_skimmer","adapted_from":"venus_harvest_01_phases_v1.json"}},
        boundary: "A reusable task definition is referenced by mission profiles. A configured execution belongs to a particular run and target."
      },
      {
        id: "task_titan_harvest_arrival_v2",
        name: "Titan Atmospheric Harvester Arrival at Luna",
        category: "Arrival / offload",
        capability: "Receive and offload harvested methane cargo for Venus-skimmer refueling",
        dependencies: ["Cryogenic storage capacity", "Receiving site readiness"],
        maturity: "Experimental V2 example",
        source: "Main game: missions_v2/tasks/task_titan_harvest_arrival_v2.json",
        notes: "Checked-in experimental V2 task example; not validated for production execution.",
        boundary: "This is a reusable task definition, not a configured mission run.",
        document: {
          task_id: "titan_harvest_arrival_v2",
          version: "2.0",
          name: "Titan Atmospheric Harvester Arrival at Luna",
          description: "Titan skimmer arrives at Luna with harvested CH₄ payload for Venus skimmer refueling.",
          launch_window: {
            departure_body: "TITAN-01",
            arrival_body: "LUNA-01",
            transit_days: 730,
            note: "Titan skimmers are a fleet — multiple departures needed for sustained operations"
          },
          payload: {
            source_gases: ["CH4"],
            ch4_kg: 50000,
            lox_for_return_kg: 10000
          },
          offload_requirements: {
            cryo_tanks_deployed: true,
            minimum_cryo_tank_count: 5
          },
          effects: [
            {
              action: "add_to_inventory",
              target: "luna_settlement",
              items: [{ name: "CH4", amount: 50000, unit: "kg" }]
            },
            {
              action: "set_status_flag",
              flag: "titan_ch4_delivery_completed",
              value: true
            }
          ],
          metadata: {
            template: "task_v2",
            type: "arrival_offload",
            craft_type: "titan_harvester_skimmer"
          }
        }
      },
      {
        id: "task_site_prep_foundation_v2",
        name: "Settlement Site Preparation",
        category: "Infrastructure prerequisite",
        capability: "Prepare the receiving site for later operations",
        dependencies: ["Target site", "Required construction assets"],
        maturity: "Referenced prerequisite",
        source: "Referenced by the Venus arrival task",
        notes: "The prototype does not yet resolve this reference to a complete authoritative task document.",
        boundary: "Do not infer a production-ready task definition from this reference alone."
      },
      {
        id: "task_print_inflatable_tank_shells_v2",
        name: "Print Inflatable Tank Shells",
        category: "Manufacturing prerequisite",
        capability: "Provide tank shells required by the receiving tank farm",
        dependencies: ["Manufacturing capability", "Required materials"],
        maturity: "Referenced prerequisite",
        source: "Referenced by the Venus arrival task",
        notes: "The prototype does not yet resolve this reference to a complete authoritative task document.",
        boundary: "Do not infer a production-ready task definition from this reference alone."
      }
    ]
  end

  def mission_fixtures
    [
      {
        id: "venus-atmospheric-harvest",
        name: "Venus Atmospheric Harvest Run",
        objective: "Maintain a repeatable supply of Venus-atmosphere cargo for Luna settlement processing.",
        scope: "Venus ↔ Luna",
        repeatability: "Repeat when craft, propellant, launch opportunity, and receiving storage are ready",
        maturity: "Design example",
        source: "Owner-confirmed operational concept; task composition remains under review",
        tasks: [
          { name: "Prepare harvester and departure resources", role: "Dispatch readiness", status: "Illustrative task grouping" },
          { name: "Harvest current Venus atmospheric composition", role: "Atmospheric collection", status: "Illustrative task grouping" },
          { name: "Return to Luna with mixed cargo", role: "Transit and arrival", status: "Illustrative task grouping" },
          { name: "Offload into prepared receiving storage", role: "Arrival / offload", status: "Experimental V2 task example available" },
          { name: "Assess next run and repeat when conditions permit", role: "Turnaround", status: "AI Manager planning responsibility" }
        ]
      },
      {
        id: "luna-precursor",
        name: "Luna Precursor Mission Profile",
        objective: "Establish initial Luna infrastructure and prepare the settlement for follow-on operations.",
        scope: "Earth → Luna",
        repeatability: "Reusable profile pattern; not a repeated cargo run",
        maturity: "Experimental V2 profile example",
        source: "Main game: missions_v2/profiles/precursor_mission_profile_v1.json",
        tasks: [
          { name: "Precursor launch and arrival", role: "Initial deployment", status: "Profile phase example" },
          { name: "Landing pad and site infrastructure", role: "Site preparation", status: "Profile phase example" },
          { name: "Tank farm preparation", role: "Receiving infrastructure", status: "Profile phase example" },
          { name: "Venus harvester arrival", role: "Atmospheric supply", status: "References experimental V2 task" }
        ]
      }
    ]
  end
end
