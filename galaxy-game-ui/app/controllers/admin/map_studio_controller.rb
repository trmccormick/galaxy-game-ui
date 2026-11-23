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
      { id: "civ4: архipelago.CivWarlordsWBSave", name: "Archipelago", collection: "Civilization IV", format: "World Builder", dimensions: "Standard", detail: "Island chains and fragmented land" }
    ]

    @planet_templates = [
      { name: "Earth-like", description: "Temperate, ocean-rich reference conditions", temperature: "288 K", pressure: "1.0 atm", water: "71%" },
      { name: "Mars-like", description: "Cold, dry and thin-atmosphere reference", temperature: "210 K", pressure: "0.006 atm", water: "0%" },
      { name: "Venus-like", description: "Hot, dense-atmosphere reference", temperature: "737 K", pressure: "92 atm", water: "0%" }
    ]
  end
end
