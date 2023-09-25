class ParticipationBlueprint < Blueprinter::Base
  # To delete after BDR make the change
  if ENV["ROLLOUT_NEW_API_VERSION"] == "1"
    identifier :id
  else
    identifier :rdv_solidarites_user_id, name: :id
  end
  fields :status, :created_by
  association :user, blueprint: UserBlueprint
end
