require 'csv'

class GraduateRecord < ApplicationRecord
  validates :crm_id, presence: true, uniqueness: true

  def self.to_csv
    CSV.generate(headers: true) do |csv|
      csv << ["CRM ID", "First Name", "Surname", "Combined Name", "Waiver Signed", "Notes"]

      all.order(:surname, :first_name).each do |record|
        csv << [
          record.crm_id, 
          record.first_name, 
          record.surname, 
          record.combined_name, 
          record.waiver_signed? ? "Yes" : "No",
          record.data&.dig("notes")
        ]
      end
    end
  end

  def self.search_by_surname(term)
    term = term.to_s.strip
    return all.order(:surname, :first_name) if term.blank?

    where("surname ILIKE :q OR combined_name ILIKE :q", q: "%#{sanitize_sql_like(term)}%")
      .order(:surname, :first_name)
      .limit(50)
  end

  def merge_data!(attributes)
    self.data = (data || {}).merge(
      attributes.to_h.transform_keys(&:to_s).reject { |_k, v| v.blank? }
    )
  end

  def combined_name
    self[:combined_name].presence || [first_name, surname].compact.join(" ")
  end

  def display_name
    combined_name.presence || "Record ##{id}"
  end

  def waiver_signed?
    data&.dig("waiver_signed") == true
  end
end