module Lookup
  # Reads curated and generated star-system JSON using the same data paths and
  # lookup semantics as the main GalaxyGame application. Source keys and nested
  # records are retained as-authored; only top-level source metadata is added.
  class StarSystemLookupService < BaseLookupService
    SYSTEMS_PATH = GalaxyGame::Paths::STAR_SYSTEMS_PATH
    GENERATED_SYSTEMS_PATH = GalaxyGame::Paths::GENERATED_STAR_SYSTEMS_PATH

    def initialize(systems_path: SYSTEMS_PATH, generated_systems_path: GENERATED_SYSTEMS_PATH)
      super()
      @systems_path = Pathname.new(systems_path)
      @generated_systems_path = Pathname.new(generated_systems_path)
      @systems = nil
    end

    def fetch(identifier)
      key = identifier.to_s.strip
      return nil if key.empty?

      records = systems
      if key.casecmp("sol").zero? || key == "SOL-01"
        sol = records.select { |record| record["_source_type"] == "curated" && record.dig("solar_system", "name").to_s.casecmp("sol").zero? }
        preferred = sol.find { |record| record["_source_file"] == "sol.json" } ||
          sol.find { |record| record["_source_file"] == "sol-complete.json" }
        return preferred if preferred
      end

      curated = records.select { |record| record["_source_type"] == "curated" }
      generated = records.select { |record| record["_source_type"] == "generated" }
      find_match(curated, key) || find_match(generated, key)
    end

    def system_exists?(identifier)
      !fetch(identifier).nil?
    end

    def all
      systems
    end

    def reload!
      @systems = nil
      systems
    end

    private

    def systems
      @systems ||= load_systems
    end

    def find_match(records, key)
      normalized = key.downcase
      records.find do |record|
        [
          record["id"],
          record.dig("solar_system", "identifier"),
          record.dig("solar_system", "name"),
          record["name"],
          File.basename(record["_source_file"].to_s, ".json")
        ].compact.any? { |value| value.to_s.downcase == normalized }
      end
    end

    def load_systems
      load_directory(@systems_path, "curated") + load_directory(@generated_systems_path, "generated")
    end

    def load_directory(directory, source_type)
      return [] unless directory.directory?

      Dir.glob(directory.join("*.json").to_s).sort.filter_map do |file|
        basename = File.basename(file)
        next if basename.start_with?("._")
        next if source_type == "curated" &&
          (basename.include?("old") || (basename.include?("complete") && !basename.start_with?("sol")))

        data = load_json_file(file)
        next unless data.is_a?(Hash)

        data.merge(
          "_source_file" => basename,
          "_source_type" => source_type
        )
      end
    end
  end
end
