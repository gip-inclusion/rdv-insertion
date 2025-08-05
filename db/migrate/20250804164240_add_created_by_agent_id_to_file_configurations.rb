class AddCreatedByAgentIdToFileConfigurations < ActiveRecord::Migration[8.0]
  def change
    add_reference :file_configurations, :created_by_agent, foreign_key: { to_table: :agents }
  end
end
