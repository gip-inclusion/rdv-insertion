class ChangeParticipationRdvSolidaritesAgentPrescripteurIdType < ActiveRecord::Migration[7.1]
  def up
    change_column :participations, :rdv_solidarites_agent_prescripteur_id, :bigint
  end

  def down
    change_column :participations, :rdv_solidarites_agent_prescripteur_id, :integer
  end
end
