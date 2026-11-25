require "rails_helper"

RSpec.describe Player::SpaceController, type: :controller do
  describe "#normalize_system_data" do
    let(:normalizer) do
      described_class.allocate.tap do |instance|
        instance.instance_variable_set(:@selected_system, { "id" => "AOL-732356", "name" => "Aki Gaia" })
      end
    end

    it "normalizes curated identifiers and meter-based orbital elements without mutating source records" do
      luna = {
        "name" => "Luna",
        "identifier" => "LUNA-01",
        "type" => "moon",
        "parent_body" => "Earth",
        "orbital_elements" => {
          "semi_major_axis" => 384_400_000.0,
          "eccentricity" => 0.0549,
          "inclination" => 5.14,
          "mean_anomaly" => 115.34
        }
      }
      source = {
        "solar_system" => { "identifier" => "SOL", "name" => "Sol" },
        "stars" => [{ "name" => "Sol", "identifier" => "SOL", "spectral_class" => "G2V", "type_of_star" => "G" }],
        "celestial_bodies" => { "major_moons" => [luna] },
        "_source_file" => "sol.json",
        "_source_type" => "curated"
      }

      result = normalizer.send(:normalize_system_data, source, "SOL")
      normalized_luna = result.fetch("bodies").first

      expect(result.dig("stars", 0, "id")).to eq("SOL")
      expect(normalized_luna["id"]).to eq("LUNA-01")
      expect(normalized_luna["identifier"]).to eq("LUNA-01")
      expect(normalized_luna["source_category"]).to eq("major_moons")
      expect(normalized_luna.dig("orbits", 0, "around")).to eq("Earth")
      expect(normalized_luna.dig("orbits", 0, "semi_major_axis_au")).to be_within(0.000001).of(0.0025696)
      expect(normalized_luna.dig("orbits", 0, "inclination_deg")).to eq(5.14)
      expect(luna).not_to have_key("id")
      expect(luna).not_to have_key("orbits")
    end

    it "flattens generated nested moons and preserves their parent and existing AU orbits" do
      source = {
        "solar_system" => { "identifier" => "AOL-732356", "name" => "Aki Gaia" },
        "stars" => [{ "name" => "Eden-A", "identifier" => "AOL-732356-A", "type" => "M0V" }],
        "celestial_bodies" => {
          "terrestrial_planets" => [{
            "name" => "Eden II",
            "identifier" => "PLANET-1",
            "type" => "terrestrial",
            "orbits" => [{ "around" => "Primary Star", "semi_major_axis_au" => 0.7025 }],
            "moons" => [{
              "name" => "Eden II I",
              "identifier" => "PLANET-1-MOON-1",
              "type" => "moon",
              "orbits" => [{ "around" => "Eden II", "semi_major_axis_au" => 0.00147 }]
            }]
          }]
        },
        "_source_file" => "aol-732356.json",
        "_source_type" => "generated"
      }

      result = normalizer.send(:normalize_system_data, source, "AOL-732356")
      planet, moon = result.fetch("bodies")

      expect(planet["id"]).to eq("PLANET-1")
      expect(planet["source_category"]).to eq("terrestrial_planets")
      expect(moon["id"]).to eq("PLANET-1-MOON-1")
      expect(moon["source_category"]).to eq("nested_moons")
      expect(moon["parent_body"]).to eq("Eden II")
      expect(moon["parent_id"]).to eq("PLANET-1")
      expect(moon.dig("orbits", 0, "semi_major_axis_au")).to eq(0.00147)
      expect(moon.dig("orbits", 0, "around")).to eq("Eden II")
    end

    it "does not invent orbital paths from star-distance measurements" do
      source = {
        "solar_system" => { "identifier" => "SOL", "name" => "Sol" },
        "stars" => [],
        "celestial_bodies" => {
          "terrestrial_planets" => [{
            "name" => "Mercury",
            "identifier" => "MERCURY-01",
            "star_distances" => [{ "star_name" => "Sol", "distance" => 57_900_000.0 }]
          }]
        }
      }

      result = normalizer.send(:normalize_system_data, source, "SOL")

      expect(result.dig("bodies", 0, "orbits")).to eq([])
    end
  end
  describe "#craft_fixtures" do
    it "represents the Venus harvester as a repeating in-system itinerary with a reported current position" do
      craft = described_class.allocate.send(:craft_fixtures).find { |item| item[:id] == "VENUS-SKIMMER-01" }

      expect(craft[:route]).to eq(["SOL"])
      expect(craft[:route_stops].map { |stop| stop[:location_id] }).to eq(["LUNA-BASE", "VENUS", "LUNA-BASE"])
      expect(craft[:route_stops].map { |stop| stop[:status] }).to eq(["completed", "current", "upcoming"])
      expect(craft[:current_position_ref]).to eq("VENUS")
      expect(craft[:destination]).to eq("Luna Base")
    end

    it "retains a stationary craft current position even when no travel route is assigned" do
      craft = described_class.allocate.send(:craft_fixtures).find { |item| item[:id] == "LUNA-CONSTRUCTION-01" }

      expect(craft[:route]).to eq(["SOL"])
      expect(craft[:route_stops]).to be_nil
      expect(craft[:current_position_ref]).to eq("LUNA-BASE")
      expect(craft[:current_position_label]).to eq("Docked at Luna Base")
    end
  end

end
