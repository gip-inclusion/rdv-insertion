class AgentBlueprint < Blueprinter::Base
  # To delete after BDR make the change
  if ENV["ROLLOUT_NEW_API_VERSION"] == "1"
    identifier :id
  else
    identifier :rdv_solidarites_agent_id, name: :id
  end
  fields :email, :first_name, :last_name
end
