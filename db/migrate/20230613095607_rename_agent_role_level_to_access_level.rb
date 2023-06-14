class RenameAgentRoleLevelToAccessLevel < ActiveRecord::Migration[7.0]
  def change
    rename_column :agent_roles, :level, :access_level
  end
end
