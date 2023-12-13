class AgentBlueprint < Blueprinter::Base
  identifier :id
  fields :email, :first_name, :last_name, :rdv_solidarites_agent_id

  view :webhook_tmp do
    field :rdv_solidarites_agent_id, name: :id
  end
end
