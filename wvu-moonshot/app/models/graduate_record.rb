class GraduateRecord < ApplicationRecord
  # Donor (graduate) check-in record for the Foundation event.
  #
  # `crm_id` is the unique key that ties the record back to Foundation CRM
  # data — names may change or duplicate, the CRM ID will not.
  # `data` is a jsonb column that flexibly holds any extra fields from the
  # donor CSV (unknown structure). Rails maps jsonb to a Hash natively.

  validates :crm_id, presence: true, uniqueness: true

  # Surname search for the check-in workflow: "staff begin typing the
  # donor's surname, the system returns matching individuals."
  def self.search_by_surname(term)
    term = term.to_s.strip
    return all.order(:surname, :first_name) if term.blank?

    where("surname ILIKE :q OR combined_name ILIKE :q", q: "%#{sanitize_sql_like(term)}%")
      .order(:surname, :first_name)
      .limit(50)
  end

  # Merge a set of key/value pairs into the jsonb store.
  # Keys are stringified and blank values are dropped so the store stays clean.
  def merge_data!(attributes)
    self.data = (data || {}).merge(
      attributes.to_h.transform_keys(&:to_s).reject { |_k, v| v.blank? }
    )
  end

  # "First Name + Surname" as shown on the staff-facing form.
  def combined_name
    self[:combined_name].presence || [first_name, surname].compact.join(" ")
  end

  # Display name for lists and search results.
  def display_name
    combined_name.presence || "Record ##{id}"
  end
end
