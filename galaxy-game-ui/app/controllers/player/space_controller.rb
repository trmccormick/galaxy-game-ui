class Player::SpaceController < ApplicationController
  layout "dashboard"

  FIXTURE_ROOT = Rails.root.join("test/fixtures/space")

  def show
    @universe = read_fixture("universe.min.json")
    @systems = @universe.fetch("systems")
    @selected_system = @systems.find { |system| system["id"] == params[:system_id] } ||
      @systems.find { |system| system["id"] == "SOL" } || @systems.first

    @system_data = read_system_fixture(@selected_system.fetch("id"))
    @craft = craft_fixtures
    @selected_craft = @craft.find { |craft| craft[:id] == params[:craft_id] } || @craft.first
    @page_title = "Space Operations"
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
        id: "LUNA-TRANSFER-01", name: "Luna Transfer 01", type: "Cargo transport",
        status: "In transit", location_system_id: "SOL", location: "Earth–Luna transfer",
        destination: "Luna Base", destination_system_id: "SOL", operation: "Luna base resupply",
        route: ["SOL"], progress: 68, updated: "Prototype telemetry"
      },
      {
        id: "VENUS-SKIMMER-01", name: "Venus Skimmer 01", type: "Atmospheric skimmer",
        status: "Operating", location_system_id: "SOL", location: "Venus orbit",
        destination: "Venus transfer orbit", destination_system_id: "SOL", operation: "Atmospheric gas collection",
        route: ["SOL"], progress: 42, updated: "Prototype telemetry"
      },
      {
        id: "EDEN-SCOUT-01", name: "Eden Scout 01", type: "Survey craft",
        status: "Awaiting dispatch", location_system_id: "AOL-732356", location: "Aki Gaia",
        destination: "Aki Gaia survey region", destination_system_id: "AOL-732356", operation: "Frontier survey",
        route: ["SOL", "AOL-732356"], progress: 0, updated: "Prototype telemetry"
      }
    ]
  end
end