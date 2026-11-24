require "rails_helper"
require "tmpdir"
require "fileutils"

RSpec.describe Lookup::StarSystemLookupService do
  around do |example|
    Dir.mktmpdir("star-system-lookup") do |root|
      @curated_path = Pathname.new(root).join("star_systems")
      @generated_path = Pathname.new(root).join("generated_star_systems")
      FileUtils.mkdir_p([@curated_path, @generated_path])
      File.write(@curated_path.join("sol.json"), {
        "solar_system" => { "identifier" => "SOL-01", "name" => "Sol" },
        "stars" => [{ "id" => "SOL", "type" => "G2V" }]
      }.to_json)
      File.write(@curated_path.join("alpha_centauri.json"), {
        "solar_system" => { "identifier" => "AC-01", "name" => "Alpha Centauri" },
        "stars" => [{ "id" => "ALPHA-CEN-A", "type" => "G2V" }, { "id" => "ALPHA-CEN-B", "type" => "K1V" }]
      }.to_json)
      File.write(@generated_path.join("aol-732356.json"), {
        "solar_system" => { "identifier" => "AOL-732356", "name" => "Eden" },
        "stars" => [{ "id" => "AKI-GAIA-STAR", "type" => "M3V" }]
      }.to_json)
      @service = described_class.new(systems_path: @curated_path, generated_systems_path: @generated_path)
      example.run
    end
  end

  it "finds curated systems by name and identifier" do
    expect(@service.fetch("Sol").dig("solar_system", "identifier")).to eq("SOL-01")
    expect(@service.fetch("SOL-01").dig("solar_system", "name")).to eq("Sol")
  end

  it "finds generated systems by identifier and case-insensitive filename" do
    expect(@service.fetch("AOL-732356").dig("solar_system", "name")).to eq("Eden")
    expect(@service.fetch("aol-732356").dig("stars", 0, "type")).to eq("M3V")
  end

  it "preserves nested source records and adds source metadata" do
    record = @service.fetch("Alpha Centauri")
    expect(record.fetch("stars").map { |star| star["type"] }).to eq(%w[G2V K1V])
    expect(record["_source_file"]).to eq("alpha_centauri.json")
    expect(record["_source_type"]).to eq("curated")
  end

  it "returns nil for unknown systems" do
    expect(@service.fetch("NOT-A-SYSTEM")).to be_nil
    expect(@service.system_exists?("NOT-A-SYSTEM")).to be false
  end
end
