class SimplifyGraduateRecordsSchema < ActiveRecord::Migration[8.1]
  def change
    # Remove hardcoded demographic columns to make the schema flexible.
    # All additional fields from the CSV will now be stored in the jsonb `data` column.
    # This allows the app to work with any CSV structure without requiring schema changes.
    
    remove_column :graduate_records, :primary_constituency, :string
    remove_column :graduate_records, :college_code, :string
    remove_column :graduate_records, :sub_department_code, :string
    remove_column :graduate_records, :class_year, :string
    remove_column :graduate_records, :combined_name, :string
  end
end
