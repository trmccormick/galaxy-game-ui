# Mirrors the main GalaxyGame application's data-root convention and mission paths.
# The prototype reads the main game's JSON data for UI/testing only; it does not
# own or modify those source files.

require "pathname"

module GalaxyGame
  module Paths
    JSON_DATA = if ENV["GALAXY_JSON_DATA_PATH"].present?
      Pathname.new(ENV["GALAXY_JSON_DATA_PATH"]).expand_path.freeze
    else
      Rails.root.join("app", "data").freeze
    end

    TEMPLATE_PATH = JSON_DATA.join("templates").freeze

    # Legacy/draft task library paths (same names as the main game).
    MISSIONS_PATH = JSON_DATA.join("missions").freeze
    TASKS_V2_PATH = MISSIONS_PATH.join("tasks_v2").freeze

    # V2 mission test/setup data paths (same names as the main game).
    MISSIONS_V2_PATH = JSON_DATA.join("missions_v2").freeze
    MISSIONS_V2_PROFILES_PATH = MISSIONS_V2_PATH.join("profiles").freeze
    MISSIONS_V2_PHASES_PATH = MISSIONS_V2_PATH.join("phases").freeze
    MISSIONS_V2_PLANS_PATH = MISSIONS_V2_PATH.join("mission_plans").freeze
    MISSIONS_V2_TASKS_PATH = MISSIONS_V2_PATH.join("tasks").freeze
    MISSIONS_V2_REGISTRY_PATH = MISSIONS_V2_PATH.join("phase_registry.json").freeze
    MISSIONS_V2_MANIFESTS_PATH = MISSIONS_V2_PATH.join("manifests").freeze
  end
end
