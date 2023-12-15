class CreateOrientations < ActiveRecord::Migration[7.0]
  def change
    create_table :orientations do |t|
      t.references :user, null: false, foreign_key: true
      t.references :organisation, null: false, foreign_key: true
      t.references :agent, null: false, foreign_key: true
      t.integer :orientation_type
      t.date :starts_at
      t.date :ends_at

      t.timestamps
    end
  end
end
