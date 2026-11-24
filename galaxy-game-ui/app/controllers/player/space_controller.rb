class Player::SpaceController < ApplicationController
  layout "dashboard"

  FIXTURE_ROOT = Rails.root.join("test/fixtures/space")

  def show
    @universe = read_fixture("universe.min.json")
    @galaxy_catalog = read_fixture("galaxy/sol_neighborhood.min.json")
    @constellation_catalog = read_fixture("galaxy/constellations.sol.min.json")
    @systems = @universe.fetch("systems")
    @craft = craft_fixtures
    requested_craft = @craft.find { |craft| craft[:id] == params[:craft_id] }
    @selected_craft = requested_craft || if params[:system_id].present?
      @craft.find { |craft| craft[:location_system_id] == params[:system_id] } || @craft.first
    else
      @craft.first
    end

    # An explicit craft focus takes precedence over a stale system parameter:
    # every Space panel must follow the craft's reported current system.
    focus_system_id = requested_craft&.dig(:location_system_id) || params[:system_id]
    @selected_system = @systems.find { |system| system["id"] == focus_system_id } ||
      @systems.find { |system| system["id"] == "SOL" } || @systems.first
    @system_data = read_system_fixture(@selected_system.fetch("id"))
    @operations = operation_fixtures
    @selected_operation = @operations.find { |operation| operation[:id] == @selected_craft[:operation_id] } || @operations.first
    @fleet_manager = params[:workspace] == "fleet_manager"
    @page_title = @fleet_manager ? "Fleet Manager" : "Space Operations"
  end

  private

  def read_fixture(filename)
    JSON.parse(FIXTURE_ROOT.join(filename).read)
  end

  def read_system_fixture(system_id)
    path = FIXTURE_ROOT.join("systems", system_id, "system.min.json")
    JSON.parse(path.read)
  rescue Errno::ENOENT, JSON::ParserError
    { "fixture" => true, "system_id" => system_id, "name" => @selected_system["name"], "star" => {}, "bodies" => [], "stations" => [], "note" => "No system fixture is available." }
  end

  # Display-only examples for exercising map selection and tracking.
  # These are not live craft records or simulation state.
  def craft_fixtures
    [
      {
        id: "LUNA-TRANSFER-01", name: "Luna Transfer 01", type: "Cargo transport", role: "Bulk supply transport",
        operation_id: "LUNA-INFRASTRUCTURE", assignment_type: "Fleet member",
        status: "In transit", location_system_id: "SOL", location: "Earth–Luna transfer",
        destination: "Luna Base", destination_system_id: "SOL", operation: "Luna infrastructure and resupply",
        route: ["SOL"], local_route: ["EARTH", "LUNA-BASE"], map_position: { x: 45, y: 45 }, progress: 68, updated: "Prototype telemetry"
      },
      {
        id: "VENUS-SKIMMER-01", name: "Venus Gas Harvester 01", type: "Robotic atmospheric skimmer", role: "Independent autonomous mission",
        operation_id: "VENUS-GAS-LOOP", assignment_type: "Independent dispatch",
        status: "Operating", location_system_id: "SOL", location: "Venus atmosphere",
        destination: "Luna Base", destination_system_id: "SOL", operation: "Recurring Luna–Venus gas delivery",
        route: ["SOL"], local_route: ["LUNA-BASE", "VENUS", "LUNA-BASE"], map_position: { x: 29, y: 38 }, progress: 42, updated: "Prototype telemetry"
      },
      {
        id: "EDEN-SCOUT-01", name: "Eden Scout 01", type: "Survey craft", role: "Independent survey dispatch",
        operation_id: "EDEN-SURVEY", assignment_type: "Independent dispatch",
        status: "Awaiting dispatch", location_system_id: "AOL-732356", location: "Aki Gaia",
        destination: "Aki Gaia survey region", destination_system_id: "AOL-732356", operation: "Aki Gaia reconnaissance",
        route: ["SOL", "AOL-732356"], local_route: ["AKI-GAIA-1", "AKI-GAIA-2A"], map_position: { x: 31, y: 42 }, progress: 0, updated: "Prototype telemetry"
      },
      {
        id: "LUNA-CONSTRUCTION-01", name: "Luna Construction Tug 01", type: "Construction support craft", role: "Orbital construction support",
        operation_id: "LUNA-INFRASTRUCTURE", assignment_type: "Fleet member",
        status: "Working", location_system_id: "SOL", location: "Luna Base",
        destination: "Luna Base", destination_system_id: "SOL", operation: "Luna infrastructure and resupply",
        route: ["SOL"], local_route: ["LUNA-BASE"], map_position: { x: 48, y: 44 }, progress: 31, updated: "Prototype telemetry"
      }
    ]
  end

  # Illustrative UI groupings only. These do not define a persisted fleet model.
  def operation_fixtures
    [
      {
        id: "LUNA-INFRASTRUCTURE", name: "Luna Infrastructure", kind: "fleet",
        objective: "Coordinate Luna base construction and resupply",
        status: "Active", craft_ids: ["LUNA-TRANSFER-01", "LUNA-CONSTRUCTION-01"]
      },
      {
        id: "VENUS-GAS-LOOP", name: "Venus Gas Delivery", kind: "independent",
        objective: "Recurring robotic Luna–Venus atmospheric harvesting and return",
        status: "Operating", craft_ids: ["VENUS-SKIMMER-01"]
      },
      {
        id: "EDEN-SURVEY", name: "Aki Gaia Reconnaissance", kind: "independent",
        objective: "Survey candidate settlement region",
        status: "Awaiting dispatch", craft_ids: ["EDEN-SCOUT-01"]
      }
    ]
  end
end