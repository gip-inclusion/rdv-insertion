class RdvBlueprint < Blueprinter::Base
  identifier :id
  fields :starts_at, :duration_in_min, :cancelled_at, :address, :uuid, :created_by,
         :users_count, :max_participants_count, :rdv_solidarites_rdv_id

  field :status do |rdv|
    rdv.read_attribute(:status)
  end

  view :extended do
    association :agents, blueprint: AgentBlueprint
    association :lieu, blueprint: LieuBlueprint
    association :motif, blueprint: MotifBlueprint
    association :users, blueprint: UserBlueprint
    association :organisation, blueprint: OrganisationBlueprint
  end
end
