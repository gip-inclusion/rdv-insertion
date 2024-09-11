class AddConnectedWithAgentConnectToAgents < ActiveRecord::Migration[7.1]
  def change
    add_column :agents, :connected_with_agent_connect_at, :datetime
  end
end
