class AddDonorFieldsToGraduateRecords < ActiveRecord::Migration[8.1]
  def change
    add_column :graduate_records, :crm_id, :string
    add_column :graduate_records, :first_name, :string
    add_column :graduate_records, :surname, :string
    add_column :graduate_records, :combined_name, :string
    add_column :graduate_records, :primary_constituency, :string
    add_column :graduate_records, :college_code, :string
    add_column :graduate_records, :sub_department_code, :string
    add_column :graduate_records, :class_year, :string

    # "Allow audio recording available for later release" → Release/Waiver completed
    rename_column :graduate_records, :audio_consent, :waiver_completed

    # CRM identifier is the reliable unique key for matching back to Foundation data.
    add_index :graduate_records, :crm_id, unique: true
    # Surname drives the event check-in search.
    add_index :graduate_records, :surname
  end
end
