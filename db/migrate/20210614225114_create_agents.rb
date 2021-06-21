class CreateAgents < ActiveRecord::Migration[6.0]
  def change
    create_table :agents do |t|
      t.string :email
      t.references :department, null: false, foreign_key: true

      t.timestamps
    end

    add_index "agents", ["email"], unique: true
  end
end
