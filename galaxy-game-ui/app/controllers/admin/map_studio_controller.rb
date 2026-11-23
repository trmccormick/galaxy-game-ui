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
end
