class AddColumnsToParticipations < ActiveRecord::Migration[8.0]
  def change
    add_column :participations, :created_by_agent_prescripteur, :boolean, default: false
    add_column :participations, :created_by_type, :string
    add_column :participations, :rdv_solidarites_created_by_id, :bigint

    Participation.where.not(created_by: nil).find_each do |participation|
      participation.update!(
        created_by_type: participation.attributes["created_by"]&.capitalize,
        created_by_agent_prescripteur: participation.rdv_solidarites_agent_prescripteur_id.present?,
        rdv_solidarites_created_by_id: participation.rdv_solidarites_agent_prescripteur_id
      )
    end

    remove_column :participations, :rdv_solidarites_agent_prescripteur_id, :bigint
    remove_column :participations, :created_by, :string
  end
end
