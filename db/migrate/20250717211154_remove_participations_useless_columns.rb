class RemoveParticipationsUselessColumns < ActiveRecord::Migration[8.0]
  def change
    remove_column :participations, :rdv_solidarites_agent_prescripteur_id, :bigint
    remove_column :participations, :created_by, :string
  end
end
