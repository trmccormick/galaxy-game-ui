class Player::SpaceController < ApplicationController
  layout "dashboard"

  FIXTURE_ROOT = Rails.root.join("test/fixtures/space")

  def show
    @universe = read_fixture("universe.min.json")
    @constellation_catalog = read_fixture("galaxy/constellations.sol.min.json")
    # The fixture universe currently supplies map topology and display metadata.
    # Enrich each system with its authoritative star records from the shared JSON
    # data tree; keep the full source arrays intact for the client renderer.
    @systems = @universe.fetch("systems").map do |system|
      source = star_system_lookup.fetch(system["id"]) || star_system_lookup.fetch(system["name"])
      stars = source&.fetch("stars", nil) || []
      system.merge("stars" => stars, "source_type" => source&.fetch("_source_type", nil))
    end
    @universe["systems"] = @systems
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
    @system_data = read_system_data(@selected_system.fetch("id"))
    @galaxy_catalog = read_neighborhood_fixture(@selected_system.fetch("id"))
    @operations = operation_fixtures
    @selected_operation = @operations.find { |operation| operation[:id] == @selected_craft[:operation_id] } || @operations.first
    @fleet_manager = params[:workspace] == "fleet_manager"
    @page_title = @fleet_manager ? "Fleet Manager" : "Space Operations"
  end

  private

  def read_fixture(filename)
    JSON.parse(FIXTURE_ROOT.join(filename).read)
  end

  # Each Galaxy View neighborhood is centered on the currently focused system.
  # Prefer a dedicated local catalog when one exists. Otherwise, when the
  # focused system and its neighbors share the sourced Sol Cartesian frame,
  # derive local positions by subtracting the focused system's vector.
  # Systems without a supported position in a common frame remain unavailable.
  def read_neighborhood_fixture(system_id)
    dedicated_path = FIXTURE_ROOT.join("galaxy", "neighborhoods", "#{system_id}.min.json")
    if dedicated_path.file?
      return JSON.parse(dedicated_path.read)
    end

    sol_catalog = read_fixture("galaxy/sol_neighborhood.min.json")
    return sol_catalog if system_id == "SOL"

    systems = sol_catalog.fetch("systems", [])
    center = systems.find { |item| item["id"] == system_id || item["seed_identifier"] == system_id }
    return nil unless center && center.dig("position", "cartesian_ly")

    center_position = center.dig("position", "cartesian_ly").transform_values(&:to_f)
    neighbors = systems.filter_map do |item|
      next if item["id"] == center["id"]

      source_position = item.dig("position", "cartesian_ly")
      next unless source_position && %w[x y z].all? { |axis| source_position.key?(axis) }

      relative = %w[x y z].to_h do |axis|
        [axis, source_position.fetch(axis).to_f - center_position.fetch(axis)]
      end
      distance = Math.sqrt(relative.values.sum { |value| value**2 })
      next if distance.zero?

      copy = JSON.parse(JSON.generate(item))
      copy["position"] = copy.fetch("position", {}).merge(
        "cartesian_ly" => relative,
        "distance_ly" => distance
      )
      copy
    end

    sol_catalog.merge(
      "reference_system_id" => system_id,
      "description" => "System-centered neighborhood derived by vector subtraction from the shared sourced Sol-relative Cartesian catalog.",
      "coordinate_conventions" => sol_catalog.fetch("coordinate_conventions", {}).merge(
        "spatial" => "Cartesian equatorial offsets in light-years relative to the focused system, derived by subtracting its sourced Sol-relative position from each neighbor's position. Axes retain the shared equatorial orientation."
      ),
      "center_system" => { "id" => center["id"], "name" => center["name"] },
      "systems" => neighbors
    )
  rescue JSON::ParserError, KeyError, TypeError
    nil
  end

  def star_system_lookup
    @star_system_lookup ||= Lookup::StarSystemLookupService.new
  end

  # Load the canonical source JSON first. The normalized view object is a thin
  # presentation adapter; the original star/body records remain unmodified.
  def read_system_data(system_id)
    source = star_system_lookup.fetch(system_id) || star_system_lookup.fetch(@selected_system["name"])
    return normalize_system_data(source, system_id) if source

    read_system_fixture(system_id)
  end

  def normalize_system_data(source, system_id)
    stars = source["stars"].is_a?(Array) ? source["stars"] : Array(source.dig("solar_system", "stars"))
    bodies = flatten_records(source["celestial_bodies"])
    stations = %w[stations orbital_facilities space_stations].flat_map do |key|
      flatten_records(source[key])
    end.uniq

    {
      "fixture" => false,
      "system_id" => source.dig("solar_system", "identifier") || source["id"] || system_id,
      "name" => @selected_system["name"] || source.dig("solar_system", "name") || source["name"],
      "source_name" => source.dig("solar_system", "name") || source["name"],
      "stars" => stars,
      "bodies" => bodies,
      "stations" => stations,
      "coordinate_frame" => source["coordinate_frame"],
      "display_layout" => source["display_layout"],
      "source_file" => source["_source_file"],
      "source_type" => source["_source_type"],
      "note" => "Loaded from #{source["_source_type"]} source JSON: #{source["_source_file"]}."
    }
  end

  # Celestial body data may be grouped by category in the source JSON. Flatten
  # only the grouping containers; retain each body hash and all nested fields.
  def flatten_records(value)
    case value
    when Array
      value.flat_map { |item| flatten_records(item) }
    when Hash
      if value.key?("id") || value.key?("name")
        [value]
      else
        value.values.flat_map { |item| flatten_records(item) }
      end
    else
      []
    end
  end

  def read_system_fixture(system_id)
    path = FIXTURE_ROOT.join("systems", system_id, "system.min.json")
    JSON.parse(path.read)
  rescue Errno::ENOENT, JSON::ParserError
    { "fixture" => true, "system_id" => system_id, "name" => @selected_system["name"], "stars" => [], "bodies" => [], "stations" => [], "note" => "No source JSON or UI system fixture is available." }
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