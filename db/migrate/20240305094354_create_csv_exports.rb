class CreateCsvExports < ActiveRecord::Migration[7.1]
  def change
    create_table :csv_exports do |t|
      t.references :agent, null: false, foreign_key: true
      t.references :structure, polymorphic: true, null: false
      t.integer :motif_category_id
      t.datetime :purged_at
      t.integer :kind

      t.timestamps
    end
  end
end
