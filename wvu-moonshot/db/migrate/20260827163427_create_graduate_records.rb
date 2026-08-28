class CreateGraduateRecords < ActiveRecord::Migration[8.1]
  def change
    create_table :graduate_records do |t|
      # Flexible store for arbitrary graduate info ingested from CSVs of
      # unknown structure. Defaults to an empty JSON object.
      t.jsonb :data, default: {}
      # Staff notes to confirm or add information during the event.
      t.text :notes
      # "Allow audio recording available for later release"
      t.boolean :audio_consent, default: false

      t.timestamps
    end

    add_index :graduate_records, :audio_consent
  end
end
