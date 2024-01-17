class CreateAgentsRdvs < ActiveRecord::Migration[7.0]
  def change
    create_join_table :agents, :rdvs do |t|
      t.bigint :id, primary_key: true
      t.index [:agent_id, :rdv_id], unique: true

      t.timestamps
    end
  end
end
