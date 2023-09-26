class RdvBlueprint < Blueprinter::Base
  # To delete after BDR make the change
  if ENV["ROLLOUT_NEW_API_VERSION"] == "1"
    identifier :id
  else
    identifier :rdv_solidarites_rdv_id, name: :id
  end
  fields :starts_at, :duration_in_min, :cancelled_at, :address, :uuid, :created_by,
         :status, :context, :users_count, :max_participants_count

  view :extended do
    association :agents, blueprint: AgentBlueprint
    association :lieu, blueprint: LieuBlueprint
    association :motif, blueprint: MotifBlueprint
    association :users, blueprint: UserBlueprint
  end
end
