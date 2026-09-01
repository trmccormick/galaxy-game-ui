require 'csv'

class GraduateRecord < ApplicationRecord
  validates :crm_id, presence: true, uniqueness: true

  def self.to_csv
    CSV.generate(headers: true) do |csv|
      core_headers = ["CRM ID", "First Name", "Surname"]
      # Add any additional data keys from records (if present) - these are from the CSV
      additional_keys = all.flat_map { |r| r.data&.keys || [] }.uniq.sort
      event_headers = ["Waiver Completed", "Notes"]
      
      csv << (core_headers + additional_keys + event_headers)

      all.order(:surname, :first_name).each do |record|
        row = [
          record.crm_id, 
          record.first_name, 
          record.surname
        ]
        # Add data values for each additional key (CSV fields)
        additional_keys.each { |key| row << record.data&.dig(key) }
        # Add our event-tracking fields at the end
        row << (record.waiver_completed? ? "Yes" : "No")
        row << record.notes
        
        csv << row
      end
    end
  end

  def self.search_by_surname(term)
    term = term.to_s.strip
    return all.order(:surname, :first_name) if term.blank?

    where("surname ILIKE :q", q: "%#{sanitize_sql_like(term)}%")
      .order(:surname, :first_name)
      .limit(50)
  end

  def merge_data!(attributes)
    self.data = (data || {}).merge(
      attributes.to_h.transform_keys(&:to_s).reject { |_k, v| v.blank? }
    )
  end

  def combined_name
    [first_name, surname].compact.join(" ")
  end

  def display_name
    combined_name.presence || "Record ##{id}"
  end

  # Convenience methods to access data fields
  def primary_constituency
    data&.dig("primary_constituency") || data&.dig("Primary Constituency")
  end

  def college_code
    data&.dig("college_code") || data&.dig("Educational/College Code") || data&.dig("College Code")
  end

  def sub_department_code
    data&.dig("sub_department_code") || data&.dig("Educational Sub-Department Code") || data&.dig("Sub-Department Code")
  end

  def class_year
    data&.dig("class_year") || data&.dig("Class Year")
  end
end