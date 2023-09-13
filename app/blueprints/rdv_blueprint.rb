class RdvBlueprint < Blueprinter::Base
  identifier :id
  fields :starts_at, :duration_in_min, :cancelled_at, :address, :uuid, :created_by,
         :status, :context, :users_count, :max_participants_count

  view :extended do
    association :agents, blueprint: AgentBlueprint
    association :participations, blueprint: ParticipationBlueprint
    association :lieu, blueprint: LieuBlueprint
    association :motif, blueprint: MotifBlueprint
    association :applicants, blueprint: ApplicantBlueprint
  end
end
