class CreateAgents < ActiveRecord::Migration[6.0]
  def change
    create_table :agents do |t|
      t.string :email
      t.references :department, null: false, foreign_key: true
    end
  end
end
