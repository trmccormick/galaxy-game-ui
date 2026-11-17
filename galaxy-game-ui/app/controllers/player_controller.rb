class PlayerController < ApplicationController
  # Player-facing views (no admin access required)
  layout :get_layout

  def planetary
    @page_title = "Planetary"

    # MOCK DATA: Representative Earth data ported from main app for prototype layout work.
    # These values are display-only; the prototype does NOT process game data.
    @planet_name = "Earth"
    @planet_type = "terrestrial"
    @radius = 6_371_000
    @gravity = 1.0

    @atmosphere = {
      pressure: 1.0,
      temperature: 288.0,
      total_mass: 5.15e19,
      composition: { "N\u2082" => 78.0, "O\u2082" => 21.0, "Ar" => 0.93 }
    }

    @biosphere = {
      biodiversity: 65.0,
      habitability: 92.0,
      life_forms: "Extensive"
    }

    @geosphere = {
      geological_activity: 50,
      tectonic_active: true,
      core_mass: 1.33e23
    }

    @hydrosphere = {
      liquid_coverage: 71.0,
      primary_liquid: "H\u2082O",
      total_liquid_mass: 1.4e21
    }

    @terrain_data = {
      elevation: [
        [-800,-750,-600,-400,-200,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0],
        [-750,-600,-300,   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0],
        [-600,-300,   0,  50, 80,120,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0],
        [-400,   0,  50,200,300,150,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0],
        [-200,   0, 80,300,400,200, 50,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0],
        [   0,   0,120,150, 80,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0],
        [   0,   0,  0, 50, 80,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0],
        [   0,   0,  0,  0, 50,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0],
        [   0,   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0],
        [   0,   0,  0,  0, 50,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0],
        [   0,   0,  0, 80,150,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0],
        [   0,   0,120,300,400,200, 50,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0],
        [   0,   0, 80,200,300,150,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0],
        [   0,   0, 50,120,300, 80,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0],
        [   0,   0,  0,150,400,200, 50,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0],
        [   0,   0,  0,200,350,180, 80,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0],
        [   0,   0,  0,180,320,160, 60,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0],
        [   0,   0,  0,100,250,120, 30,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0]
      ],
      biomes: [
        ["ocean","ocean","ocean","ocean","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast"],
        ["ocean","ocean","ocean","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast"],
        ["ocean","ocean","coast","tropical_rainforest","tropical_rainforest","tropical_rainforest","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast"],
        ["ocean","coast","tropical_rainforest","temperate_forest","temperate_forest","grassland","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast"],
        ["ocean","coast","temperate_forest","temperate_forest","mountain","grassland","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast"],
        ["coast","coast","temperate_forest","grassland","plains","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast"],
        ["coast","coast","coast","grassland","plains","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast"],
        ["coast","coast","coast","coast","grassland","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast"],
        ["coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast"],
        ["coast","coast","coast","coast","grassland","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast"],
        ["coast","coast","coast","grassland","plains","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast"],
        ["coast","coast","temperate_forest","temperate_forest","mountain","grassland","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast"],
        ["ocean","coast","temperate_forest","temperate_forest","mountain","grassland","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast"],
        ["ocean","coast","tropical_rainforest","temperate_forest","temperate_forest","grassland","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast"],
        ["ocean","ocean","tropical_rainforest","tropical_rainforest","tropical_rainforest","tropical_rainforest","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast"],
        ["ocean","ocean","ocean","tropical_rainforest","temperate_forest","grassland","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast"],
        ["ocean","ocean","ocean","ocean","temperate_forest","temperate_forest","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast"],
        ["ocean","ocean","ocean","ocean","ocean","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast","coast"]
      ],
      resource_grid: [
        ["none","none","none","none","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock"],
        ["none","none","none","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock"],
        ["none","none","rock","iron","iron","iron","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock"],
        ["none","rock","iron","iron","iron","iron","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock"],
        ["none","rock","iron","iron","iron","iron","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock"],
        ["rock","rock","iron","iron","iron","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock"],
        ["rock","rock","rock","iron","iron","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock"],
        ["rock","rock","rock","rock","iron","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock"],
        ["rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock"],
        ["rock","rock","rock","rock","iron","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock"],
        ["rock","rock","rock","iron","iron","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock"],
        ["rock","rock","iron","iron","iron","iron","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock"],
        ["none","rock","iron","iron","iron","iron","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock"],
        ["none","rock","iron","iron","iron","iron","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock"],
        ["none","none","iron","iron","iron","iron","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock"],
        ["none","none","iron","iron","iron","iron","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock"],
        ["none","none","iron","iron","iron","iron","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock"],
        ["none","none","rock","iron","iron","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock"],
        ["none","none","none","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock","rock"]
      ],
      quality_score: "mock",
      generation_method: "prototype_mock_data"
    }
  end

  private

  def get_layout
    # Use dashboard layout for player views (has sidebar nav)
    "dashboard"
  end
end
