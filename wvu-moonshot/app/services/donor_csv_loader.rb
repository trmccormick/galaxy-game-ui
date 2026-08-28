require "csv"

# Loads the donor (graduate) CSV from the `data/` folder into the database.
#
# The CSV is the source of truth for donor demographics and may be replaced
# with the final Foundation dataset at any time. Records are upserted using
# the unique CRM identifier, so re-running the loader refreshes demographics
# without clobbering event data (waiver status, corrections/notes).
#
# Expected columns (header names are matched case-insensitively and are
# tolerant of the Foundation's exact wording):
#   CRM ID, First Name, Surname, Primary Constituency,
#   Educational/College Code, Educational Sub-Department Code, Class Year
#
# Any additional columns are preserved in the jsonb `data` store.
class DonorCsvLoader
  COLUMN_MAP = {
    "crm id" => :crm_id,
    "crm_id" => :crm_id,
    "first name" => :first_name,
    "surname" => :surname,
    "last name" => :surname,
    "primary constituency" => :primary_constituency,
    "educational/college code" => :college_code,
    "college code" => :college_code,
    "educational sub-department code" => :sub_department_code,
    "sub-department code" => :sub_department_code,
    "sub department code" => :sub_department_code,
    "class year" => :class_year
  }.freeze

  KNOWN_KEYS = COLUMN_MAP.values

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
        record.update!(**attrs.except(:data))
        updated += 1
      else
        GraduateRecord.create!(**attrs)
        created += 1
      end
    end

    Result.new(created: created, updated: updated, skipped: skipped)
  end

  private

  # Map a CSV row onto model attributes. Unrecognized columns are kept in
  # the jsonb `data` store so no information from the CSV is lost.
  def map_row(row)
    attrs = { data: {} }
    row.each do |header, value|
      value = value.to_s.strip
      key = COLUMN_MAP[header.to_s.downcase]
      if key
        attrs[key] = value.presence
      else
        attrs[:data][header] = value.presence
      end
    end
    attrs
  end
end
