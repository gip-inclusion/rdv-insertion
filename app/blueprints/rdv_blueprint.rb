class RdvBlueprint < Blueprinter::Base
  identifier :id
  fields :starts_at, :duration_in_min, :cancelled_at, :address, :uuid, :created_by,
         :status, :users_count, :max_participants_count, :rdv_solidarites_rdv_id

  view :extended do
    association :agents, blueprint: AgentBlueprint
    association :lieu, blueprint: LieuBlueprint
    association :motif, blueprint: MotifBlueprint
    association :users, blueprint: UserBlueprint
    association :organisation, blueprint: OrganisationBlueprint
  end

  view :webhook_tmp do
    field :rdv_solidarites_rdv_id, name: :id
    association :agents, blueprint: AgentBlueprint, view: :webhook_tmp
    association :lieu, blueprint: LieuBlueprint, view: :webhook_tmp
    association :motif, blueprint: MotifBlueprint, view: :webhook_tmp
    association :users, blueprint: UserBlueprint, view: :webhook_tmp
    association :organisation, blueprint: OrganisationBlueprint, view: :webhook_tmp
  end
end
