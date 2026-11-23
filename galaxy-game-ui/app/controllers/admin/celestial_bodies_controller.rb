class Admin::CelestialBodiesController < Admin::BaseController
  layout "dashboard"

  before_action :set_celestial_body, only: :show

  def index
    @bodies = body_fixtures
    @body_counts = {
      total: @bodies.length,
      planets: @bodies.count { |body| body[:category] == "Planet" },
      moons: @bodies.count { |body| body[:category] == "Moon" },
      minor_bodies: @bodies.count { |body| body[:category] == "Minor body" }
    }
    @systems = @bodies.map { |body| body[:system] }.uniq.sort
    @categories = @bodies.map { |body| body[:category] }.uniq.sort
  end

  def show
  end

  private

  def set_celestial_body
    @celestial_body = body_fixtures.find { |body| body[:id] == params[:id] }
    raise ActiveRecord::RecordNotFound, "Prototype celestial body not found" unless @celestial_body
  end

  def body_fixtures
    [
      {
        id: "earth", name: "Earth", category: "Planet", system: "Sol",
        status: "Reference body", radius: "6,371 km", gravity: "1.000 g",
        temperature: "288 K", atmosphere: "Present", hydrosphere: "Present",
        geosphere: "Present", biosphere: "Present", settlements: 1,
        provenance: "Reference fixture", description: "Baseline terrestrial world with established environmental reference values."
      },
      {
        id: "mars", name: "Mars", category: "Planet", system: "Sol",
        status: "Survey reference", radius: "3,390 km", gravity: "0.379 g",
        temperature: "210 K", atmosphere: "Present · thin", hydrosphere: "Trace / subsurface",
        geosphere: "Present", biosphere: "Not established", settlements: 0,
        provenance: "Reference fixture", description: "Cold terrestrial world with a thin atmosphere and mapped surface regions."
      },
      {
        id: "luna", name: "Luna", category: "Moon", system: "Sol",
        status: "Operational interest", radius: "1,737 km", gravity: "0.166 g",
        temperature: "Variable", atmosphere: "Exosphere", hydrosphere: "Polar ice deposits",
        geosphere: "Present", biosphere: "Absent", settlements: 1,
        provenance: "Design fixture", description: "Airless rocky moon with polar volatile resources and established settlement planning."
      },
      {
        id: "venus", name: "Venus", category: "Planet", system: "Sol",
        status: "Survey reference", radius: "6,052 km", gravity: "0.904 g",
        temperature: "737 K", atmosphere: "Present · dense", hydrosphere: "No stable surface liquid",
        geosphere: "Present", biosphere: "Not established", settlements: 0,
        provenance: "Reference fixture", description: "Hot terrestrial world with a dense carbon-dioxide atmosphere."
      },
      {
        id: "titan", name: "Titan", category: "Moon", system: "Sol",
        status: "Survey reference", radius: "2,575 km", gravity: "0.138 g",
        temperature: "94 K", atmosphere: "Present · nitrogen", hydrosphere: "Methane / ethane lakes",
        geosphere: "Present", biosphere: "Not established", settlements: 0,
        provenance: "Reference fixture", description: "Large icy moon with a substantial nitrogen atmosphere and surface hydrocarbon cycle."
      },
      {
        id: "phobos", name: "Phobos", category: "Minor body", system: "Sol",
        status: "Survey reference", radius: "11 km", gravity: "Very low",
        temperature: "Variable", atmosphere: "Absent", hydrosphere: "Not established",
        geosphere: "Present", biosphere: "Absent", settlements: 0,
        provenance: "Illustrative fixture", description: "Small irregular Martian moon included to exercise non-planet body inspection."
      }
    ]
  end
end
