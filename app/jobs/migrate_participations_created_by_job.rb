class MigrateParticipationsCreatedByJob < ApplicationJob
  def perform
    Participation.where(created_by_type: nil).where.not(created_by: nil).find_each do |participation|
      participation.update!(
        created_by_type: participation.attributes["created_by"]&.capitalize,
        created_by_agent_prescripteur: participation.rdv_solidarites_agent_prescripteur_id.present?,
        rdv_solidarites_created_by_id: participation.rdv_solidarites_agent_prescripteur_id
      )
    end
  end
end
