module Lookup
  # Shared JSON-reading behavior for UI lookup services. Paths are supplied by
  # GalaxyGame::Paths so the app is independent of the Docker mount location.
  class BaseLookupService
    attr_reader :data_path

    def initialize(data_path: GalaxyGame::Paths::JSON_DATA)
      @data_path = Pathname.new(data_path)
    end

    protected

    def load_json_file(file_path)
      JSON.parse(File.read(file_path))
    rescue JSON::ParserError => e
      Rails.logger.error("Invalid JSON in #{file_path}: #{e.message}")
      nil
    rescue SystemCallError => e
      Rails.logger.error("Unable to read #{file_path}: #{e.message}")
      nil
    end
  end
end
