require "csv"

# Loads the donor (graduate) CSV from the `data/` folder into the database.
#
# The CSV is the source of truth for donor demographics and may be replaced
# at any time. Records are upserted using the unique CRM identifier, so re-running
# the loader refreshes demographics without clobbering event data (waiver status, notes).
#
# Expected columns (case-insensitive, header names are flexible):
#   CRM ID (or crm_id) — Required, unique identifier
#   First Name (or first_name) — Required
#   Surname (or surname, last_name) — Required
#   All other columns — Stored in the jsonb `data` field
#
# This design allows the app to work with ANY CSV structure without schema changes.
class DonorCsvLoader
  # Map common column name variations to model attributes
  COLUMN_MAP = {
    "crm id" => :crm_id,
    "crm_id" => :crm_id,
    "first name" => :first_name,
    "first_name" => :first_name,
    "surname" => :surname,
    "last name" => :surname,
    "lastname" => :surname
  }.freeze

  KNOWN_KEYS = COLUMN_MAP.values.freeze

  Result = Struct.new(:created, :updated, :skipped, keyword_init: true)

  def self.call(path = nil)
    new(path).call
  end

  def initialize(path = nil)
    @path = path || Rails.root.join("data", "donors.csv")
  end

  def call
    raise "Donor CSV not found at #{@path}" unless File.exist?(@path)

    created = updated = skipped = 0

    CSV.foreach(@path, headers: true) do |row|
      attrs = map_row(row)
      next skipped += 1 if attrs[:crm_id].blank?

      record = GraduateRecord.find_by(crm_id: attrs[:crm_id])
      if record
        # Update only the model attributes (first_name, surname, data)
        # Preserve event data: waiver_completed, notes are never overwritten
        record.update!(**attrs.except(:data))
        record.merge_data!(attrs[:data])
        record.save!
        updated += 1
      else
        GraduateRecord.create!(**attrs)
        created += 1
      end
    end

    Result.new(created: created, updated: updated, skipped: skipped)
  end

  private

  # Map a CSV row onto model attributes. Known columns map to model fields,
  # unknown columns are stored in the jsonb `data` field for flexibility.
  def map_row(row)
    attrs = { data: {} }
    row.each do |header, value|
      value = value.to_s.strip
      key = COLUMN_MAP[header.to_s.downcase]
      if key
        attrs[key] = value.presence
      else
        # Store unrecognized columns in jsonb for flexibility
        attrs[:data][header] = value.presence
      end
    end
    attrs
  end
end
