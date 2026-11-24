require "rails_helper"

RSpec.describe GalaxyGame::Paths do
  describe "star system data locations" do
    it "exposes curated and generated systems under the shared JSON data root" do
      expect(described_class::STAR_SYSTEMS_PATH).to eq(described_class::JSON_DATA.join("star_systems"))
      expect(described_class::GENERATED_STAR_SYSTEMS_PATH).to eq(described_class::JSON_DATA.join("generated_star_systems"))
    end
  end

  describe "mission data locations" do
    it "keeps the draft task library separate from the V2 test/setup data" do
      expect(described_class::TASKS_V2_PATH).to eq(
        described_class::JSON_DATA.join("missions", "tasks_v2")
      )
      expect(described_class::MISSIONS_V2_PATH).to eq(
        described_class::JSON_DATA.join("missions_v2")
      )
      expect(described_class::MISSIONS_V2_TASKS_PATH).to eq(
        described_class::MISSIONS_V2_PATH.join("tasks")
      )
      expect(described_class::TASKS_V2_PATH).not_to eq(
        described_class::MISSIONS_V2_TASKS_PATH
      )
    end

    it "exposes the same profile, phase, plan, registry, and manifest locations as the main game" do
      root = described_class::MISSIONS_V2_PATH

      expect(described_class::MISSIONS_V2_PROFILES_PATH).to eq(root.join("profiles"))
      expect(described_class::MISSIONS_V2_PHASES_PATH).to eq(root.join("phases"))
      expect(described_class::MISSIONS_V2_PLANS_PATH).to eq(root.join("mission_plans"))
      expect(described_class::MISSIONS_V2_REGISTRY_PATH).to eq(root.join("phase_registry.json"))
      expect(described_class::MISSIONS_V2_MANIFESTS_PATH).to eq(root.join("manifests"))
    end
  end
end
