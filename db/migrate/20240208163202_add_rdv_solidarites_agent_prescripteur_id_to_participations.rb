class AddRdvSolidaritesAgentPrescripteurIdToParticipations < ActiveRecord::Migration[7.0]
  def change
    add_column :participations, :rdv_solidarites_agent_prescripteur_id, :integer
  end
end
