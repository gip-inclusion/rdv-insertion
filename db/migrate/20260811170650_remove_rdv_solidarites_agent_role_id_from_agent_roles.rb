class RemoveRdvSolidaritesAgentRoleIdFromAgentRoles < ActiveRecord::Migration[8.1]
  def change
    remove_column :agent_roles, :rdv_solidarites_agent_role_id, :bigint
  end
end
