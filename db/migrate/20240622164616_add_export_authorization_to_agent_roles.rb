class AddExportAuthorizationToAgentRoles < ActiveRecord::Migration[7.1]
  def change
    add_column :agent_roles, :export_authorization, :boolean, default: false
  end
end
