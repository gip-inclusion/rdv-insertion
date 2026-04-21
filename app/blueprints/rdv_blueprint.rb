class RdvBlueprint < ApplicationBlueprint
  identifier :id
  fields :duration_in_min, :cancelled_at, :address, :uuid, :created_by,
         :status, :users_count, :max_participants_count, :rdv_solidarites_rdv_id

  field :starts_at do |rdv, _options|
    rdv.starts_at_in_time_zone
  end

  view :extended do
    association :agents, blueprint: AgentBlueprint
    association :lieu, blueprint: LieuBlueprint
    association :motif, blueprint: MotifBlueprint
    association :users, blueprint: UserBlueprint
    association :organisation, blueprint: OrganisationBlueprint
    association :participations, blueprint: ParticipationBlueprint
  end
end
