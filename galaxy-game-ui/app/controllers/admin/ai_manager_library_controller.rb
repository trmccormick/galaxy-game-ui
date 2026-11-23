class Admin::AiManagerLibraryController < Admin::BaseController
  layout "dashboard"

  # Display-only fixtures for the shared task and mission libraries.
  # The V2 source definitions in the main game are experimental examples,
  # not evidence that this prototype is connected to a live execution engine.
  def tasks
    @tasks = [
      {
        id: "task_venus_harvest_arrival_v2",
        name: "Venus Atmospheric Harvester Arrival at Luna",
        category: "Arrival / offload",
        capability: "Receive and offload harvested atmospheric cargo",
        dependencies: "Luna tank-farm preparation; inflatable tank deployment",
        maturity: "Experimental V2 example",
        source: "Main game: missions_v2/tasks/task_venus_harvest_arrival_v2.json"
      },
      {
        id: "task_site_prep_foundation_v2",
        name: "Settlement Site Preparation",
        category: "Infrastructure prerequisite",
        capability: "Prepare the receiving site for later operations",
        dependencies: "Target site and required construction assets",
        maturity: "Referenced prerequisite",
        source: "Referenced by the Venus arrival task"
      },
      {
        id: "task_print_inflatable_tank_shells_v2",
        name: "Print Inflatable Tank Shells",
        category: "Manufacturing prerequisite",
        capability: "Provide tank shells required by the receiving tank farm",
        dependencies: "Manufacturing capability and materials",
        maturity: "Referenced prerequisite",
        source: "Referenced by the Venus arrival task"
      }
    ]
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
