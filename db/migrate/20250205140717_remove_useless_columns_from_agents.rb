class RemoveUselessColumnsFromAgents < ActiveRecord::Migration[7.1]
  def change
    remove_column :agents, :connected_with_agent_connect_at, :datetime
    remove_column :agents, :inclusion_connect_open_id_sub, :string
  end
end
