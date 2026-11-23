class Admin::MapStudioController < Admin::BaseController
  layout "dashboard"

  # Fixture-backed overview for the UI prototype; no production map data is read.
  def index
    @stats = [
      { label: "Source maps", value: "42", detail: "FreeCiv and Civ4 collections", tone: "cyan" },
      { label: "Generated maps", value: "06", detail: "Prototype library records", tone: "purple" },
      { label: "Celestial bodies", value: "09", detail: "Available example targets", tone: "green" },
      { label: "Recent generations", value: "02", detail: "Illustrative recent activity", tone: "amber" }
    ]
    @source_collections = [
      { name: "FreeCiv maps", count: 27, format: "Scenario and world map sources", status: "Available" },
      { name: "Civilization IV maps", count: 15, format: "World Builder terrain sources", status: "Available" }
    ]
    @recent_activities = [
      { name: "Mars regional terrain generated", target: "Mars · Northern lowlands", source: "FreeCiv + procedural reconstruction", time: "2 hours ago", status: "Complete" },
      { name: "Luna source collection indexed", target: "Luna · Marius Hills region", source: "Civ4 terrain reference", time: "Yesterday", status: "Indexed" },
      { name: "Earth terrain baseline reviewed", target: "Earth · Global", source: "Elevation and geology reference", time: "3 days ago", status: "Reviewed" }
    ]
  end

  # Illustrative generation workspace. Fixtures intentionally replace live map
  # directories and celestial-body records until the prototype is wired to data.
  def generate
    @target_worlds = [
      { name: "Earth", kind: "Terrestrial · baseline reference", id: "earth" },
      { name: "Mars", kind: "Terrestrial · regional reconstruction", id: "mars" },
      { name: "Venus", kind: "Terrestrial · volcanic surface", id: "venus" },
      { name: "Luna", kind: "Airless rocky body", id: "luna" },
      { name: "Eden-1", kind: "Extrasolar · generated world", id: "eden-1" }
    ]

    @source_maps = [
      { id: "freeciv:earth-large.sav", name: "Earth Large", collection: "FreeCiv", format: "Scenario map", dimensions: "180 × 90", detail: "Continental-scale landforms and ocean basins" },
      { id: "freeciv:earth-classic.sav", name: "Earth Classic", collection: "FreeCiv", format: "World map", dimensions: "120 × 60", detail: "Balanced global terrain distribution" },
      { id: "freeciv:highlands.sav", name: "Highlands", collection: "FreeCiv", format: "Regional map", dimensions: "80 × 50", detail: "Mountain chains, plateaus and uplands" },
      { id: "civ4:terra.Civ4WorldBuilderSave", name: "Terra", collection: "Civilization IV", format: "World Builder", dimensions: "Earth-style", detail: "Large landmasses with varied coastlines" },
      { id: "civ4:highlands.CivBeyondSwordWBSave", name: "Highlands", collection: "Civilization IV", format: "World Builder", dimensions: "Standard", detail: "Rugged relief and inland basins" },
      { id: "civ4:archipelago.CivWarlordsWBSave", name: "Archipelago", collection: "Civilization IV", format: "World Builder", dimensions: "Standard", detail: "Island chains and fragmented land" }
    ]

    @planet_templates = [
      { name: "Earth-like", description: "Temperate, ocean-rich reference conditions", temperature: "288 K", pressure: "1.0 atm", water: "71%" },
      { name: "Mars-like", description: "Cold, dry and thin-atmosphere reference", temperature: "210 K", pressure: "0.006 atm", water: "0%" },
      { name: "Venus-like", description: "Hot, dense-atmosphere reference", temperature: "737 K", pressure: "92 atm", water: "0%" }
    ]
  end

  # Library fixtures mirror the main Map Studio browse metadata. Applying a
  # map remains deliberately unavailable in this UI-only prototype.
  def browse
    @generated_maps = [
      { id: "mars_northern_lowlands_20261121.json", name: "Mars · Northern Lowlands", planet: "Mars", planet_type: "Terrestrial", created_at: "2026-11-21T14:32:00Z", quality_score: 8.7, description: "Regional reconstruction emphasizing the northern plains, basin margins and major elevation transitions.", biome_focus: "Arid", complexity: "Complex", applied: false, source_maps: ["FreeCiv · Earth Large", "Civ4 · Highlands"], dimensions: "800 × 400", file_size: "2.4 MB" },
      { id: "earth_global_baseline_20261120.json", name: "Earth · Global Baseline", planet: "Earth", planet_type: "Terrestrial", created_at: "2026-11-20T09:15:00Z", quality_score: 9.4, description: "Global reference terrain with broad continental structure, ocean basins and varied relief.", biome_focus: "Balanced", complexity: "Complex", applied: true, source_maps: ["FreeCiv · Earth Classic", "Civ4 · Terra"], dimensions: "800 × 400", file_size: "3.1 MB" },
      { id: "luna_marius_hills_20261118.json", name: "Luna · Marius Hills Region", planet: "Luna", planet_type: "Airless rocky body", created_at: "2026-11-18T18:05:00Z", quality_score: 8.2, description: "Regional lunar terrain reference with volcanic plains, elevated terrain and skylight surroundings.", biome_focus: "Arid", complexity: "Normal", applied: false, source_maps: ["Civ4 · Highlands"], dimensions: "600 × 300", file_size: "1.7 MB" },
      { id: "venus_global_reference_20261116.json", name: "Venus · Global Reference", planet: "Venus", planet_type: "Terrestrial", created_at: "2026-11-16T12:40:00Z", quality_score: 7.9, description: "Global surface baseline for broad highland regions, volcanic provinces and lowland plains.", biome_focus: "Continental", complexity: "Complex", applied: false, source_maps: ["FreeCiv · Earth Large"], dimensions: "800 × 400", file_size: "2.8 MB" },
      { id: "eden1_initial_terrain_20261114.json", name: "Eden-1 · Initial Terrain", planet: "Eden-1", planet_type: "Extrasolar terrestrial", created_at: "2026-11-14T16:20:00Z", quality_score: 8.5, description: "Plausible initial landform distribution prepared as a starting terrain state for an extrasolar world.", biome_focus: "Balanced", complexity: "Normal", applied: false, source_maps: ["Civ4 · Terra", "FreeCiv · Highlands"], dimensions: "800 × 400", file_size: "2.2 MB" },
      { id: "mars_tharsis_test_20261110.json", name: "Mars · Tharsis Test", planet: "Mars", planet_type: "Terrestrial", created_at: "2026-11-10T08:10:00Z", quality_score: 6.8, description: "Earlier terrain reconstruction test covering the Tharsis region and surrounding volcanic uplands.", biome_focus: "Arid", complexity: "Simple", applied: false, source_maps: ["FreeCiv · Highlands"], dimensions: "400 × 200", file_size: "820 KB" }
    ]
    @map_stats = {
      total: @generated_maps.size,
      applied: @generated_maps.count { |map| map[:applied] },
      pending: @generated_maps.count { |map| !map[:applied] },
      average_quality: (@generated_maps.sum { |map| map[:quality_score] } / @generated_maps.size).round(1)
    }
  end

  # Fixture-backed inspection of a reusable generated-map artifact.
  # Metrics that are placeholders in the legacy controller are deliberately
  # shown as unassessed rather than presented as validated quality findings.
  def analyze
    fixtures = {
      "mars_northern_lowlands_20261121.json" => {
        name: "Mars · Northern Lowlands", planet: "Mars", planet_type: "Terrestrial",
        created_at: "2026-11-21 14:32 UTC", quality_score: 8.7,
        description: "Regional reconstruction emphasizing the northern plains, basin margins and major elevation transitions.",
        dimensions: "800 × 400", tile_count: 320_000, complexity: "Complex", biome_focus: "Arid",
        source_maps: ["FreeCiv · Earth Large", "Civ4 · Highlands"],
        biome_counts: { "Lowland" => 118_400, "Rocky" => 83_200, "Highland" => 64_000, "Dune" => 35_200, "Polar" => 19_200 }
      },
      "earth_global_baseline_20261120.json" => {
        name: "Earth · Global Baseline", planet: "Earth", planet_type: "Terrestrial",
        created_at: "2026-11-20 09:15 UTC", quality_score: 9.4,
        description: "Global reference terrain with broad continental structure, ocean basins and varied relief.",
        dimensions: "800 × 400", tile_count: 320_000, complexity: "Complex", biome_focus: "Balanced",
        source_maps: ["FreeCiv · Earth Classic", "Civ4 · Terra"],
        biome_counts: { "Ocean" => 156_800, "Grassland" => 54_400, "Forest" => 38_400, "Desert" => 28_800, "Mountain" => 22_400, "Tundra" => 19_200 }
      },
      "luna_marius_hills_20261118.json" => {
        name: "Luna · Marius Hills Region", planet: "Luna", planet_type: "Airless rocky body",
        created_at: "2026-11-18 18:05 UTC", quality_score: 8.2,
        description: "Regional lunar terrain reference with volcanic plains, elevated terrain and skylight surroundings.",
        dimensions: "600 × 300", tile_count: 180_000, complexity: "Normal", biome_focus: "Arid",
        source_maps: ["Civ4 · Highlands"],
        biome_counts: { "Mare basalt" => 72_000, "Highland" => 50_400, "Rugged upland" => 39_600, "Cratered terrain" => 18_000 }
      },
      "venus_global_reference_20261116.json" => {
        name: "Venus · Global Reference", planet: "Venus", planet_type: "Terrestrial",
        created_at: "2026-11-16 12:40 UTC", quality_score: 7.9,
        description: "Global surface baseline for broad highland regions, volcanic provinces and lowland plains.",
        dimensions: "800 × 400", tile_count: 320_000, complexity: "Complex", biome_focus: "Continental",
        source_maps: ["FreeCiv · Earth Large"],
        biome_counts: { "Volcanic plains" => 128_000, "Lowland" => 83_200, "Tessera highland" => 64_000, "Rift zone" => 44_800 }
      },
      "eden1_initial_terrain_20261114.json" => {
        name: "Eden-1 · Initial Terrain", planet: "Eden-1", planet_type: "Extrasolar terrestrial",
        created_at: "2026-11-14 16:20 UTC", quality_score: 8.5,
        description: "Plausible initial landform distribution prepared as a starting terrain state for an extrasolar world.",
        dimensions: "800 × 400", tile_count: 320_000, complexity: "Normal", biome_focus: "Balanced",
        source_maps: ["Civ4 · Terra", "FreeCiv · Highlands"],
        biome_counts: { "Ocean" => 112_000, "Temperate plain" => 76_800, "Upland" => 57_600, "Dry basin" => 44_800, "Cold region" => 28_800 }
      },
      "mars_tharsis_test_20261110.json" => {
        name: "Mars · Tharsis Test", planet: "Mars", planet_type: "Terrestrial",
        created_at: "2026-11-10 08:10 UTC", quality_score: 6.8,
        description: "Earlier terrain reconstruction test covering the Tharsis region and surrounding volcanic uplands.",
        dimensions: "400 × 200", tile_count: 80_000, complexity: "Simple", biome_focus: "Arid",
        source_maps: ["FreeCiv · Highlands"],
        biome_counts: { "Volcanic upland" => 32_000, "Rocky plain" => 24_000, "Basin" => 16_000, "Cratered terrain" => 8_000 }
      }
    }
    @map = fixtures[params[:id].to_s]
    unless @map
      redirect_to admin_map_studio_browse_path, alert: "That fixture map is not available in the prototype."
      return
    end

    @map[:id] = params[:id]
    @analysis = {
      biome_count: @map[:biome_counts].size,
      tile_count: @map[:tile_count],
      source_count: @map[:source_maps].size,
      terrain_diversity: (@map[:biome_counts].size / 10.0).round(2),
      resource_balance: nil,
      strategic_features: nil,
      overall_score: nil
    }
  end

  # Review a generated artifact against a destination body's current terrain.
  # Destination records are illustrative fixtures; no production bodies are read.
  def apply
    load_apply_review
  end

  # Prototype-only confirmation. This action deliberately performs no writes.
  def simulate_apply
    load_apply_review
    @simulation_result = true
    render :apply
  end

  private

  def load_apply_review
    maps = {
      "mars_northern_lowlands_20261121.json" => ["Mars · Northern Lowlands", "Mars", "800 × 400", "2.4 MB", "FreeCiv · Earth Large; Civ4 · Highlands"],
      "earth_global_baseline_20261120.json" => ["Earth · Global Baseline", "Earth", "800 × 400", "3.1 MB", "FreeCiv · Earth Classic; Civ4 · Terra"],
      "luna_marius_hills_20261118.json" => ["Luna · Marius Hills Region", "Luna", "600 × 300", "1.7 MB", "Civ4 · Highlands"],
      "venus_global_reference_20261116.json" => ["Venus · Global Reference", "Venus", "800 × 400", "2.8 MB", "FreeCiv · Earth Large"],
      "eden1_initial_terrain_20261114.json" => ["Eden-1 · Initial Terrain", "Eden-1", "800 × 400", "2.2 MB", "Civ4 · Terra; FreeCiv · Highlands"],
      "mars_tharsis_test_20261110.json" => ["Mars · Tharsis Test", "Mars", "400 × 200", "820 KB", "FreeCiv · Highlands"]
    }
    record = maps[params[:id].to_s]
    unless record
      redirect_to admin_map_studio_browse_path, alert: "That fixture map is not available in the prototype."
      return
    end

    @map = { id: params[:id], name: record[0], target: record[1], dimensions: record[2], file_size: record[3], sources: record[4].split("; ") }
    @destination_bodies = [
      { id: "earth", name: "Earth", kind: "Terrestrial planet", terrain: "Present · existing baseline", source: "NASA / imported baseline" },
      { id: "mars", name: "Mars", kind: "Terrestrial planet", terrain: "Present · automatically generated", source: "StarSim automatic terrain" },
      { id: "luna", name: "Luna", kind: "Airless major moon", terrain: "Present · regional terrain", source: "StarSim automatic terrain" },
      { id: "venus", name: "Venus", kind: "Terrestrial planet", terrain: "Present · existing baseline", source: "StarSim automatic terrain" },
      { id: "eden-1", name: "Eden-1", kind: "Extrasolar terrestrial world", terrain: "Not yet populated", source: "No stored terrain fixture" },
      { id: "titan", name: "Titan", kind: "Major moon", terrain: "Present · automatically generated", source: "StarSim automatic terrain" }
    ]
    @selected_body = @destination_bodies.find { |body| body[:id] == params[:body_id].to_s }
    @target_matches = @selected_body && @selected_body[:name] == @map[:target]
    @has_existing_terrain = @selected_body && !@selected_body[:terrain].start_with?("Not yet")
  end

end
