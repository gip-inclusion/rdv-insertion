class CreateOrientations < ActiveRecord::Migration[7.0]
  def change
    create_table :orientations do |t|
      t.references :user, null: false, foreign_key: true
      t.references :organisation, null: false, foreign_key: true
      t.references :agent, null: false, foreign_key: true
      t.integer :type
      t.datetime :starts_at
      t.datetime :ends_at

      t.timestamps
    end
  end
end
