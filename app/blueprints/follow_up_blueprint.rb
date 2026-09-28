class FollowUpBlueprint < ApplicationBlueprint
  identifier :id
  fields :created_at, :status, :human_status, :closed_at
  association :motif_category, blueprint: MotifCategoryBlueprint
  association :participations, blueprint: ParticipationBlueprint

  view :plateforme_inclusion do
    association :participations, blueprint: ParticipationBlueprint, view: :plateforme_inclusion
    association :invitations, blueprint: InvitationBlueprint, view: :without_motif_category
  end
end
