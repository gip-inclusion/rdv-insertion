class AddAttributesToAgents < ActiveRecord::Migration[7.0]
  def change
    add_column :agents, :rdv_solidarites_agent_id, :bigint
    add_column :agents, :first_name, :string
    add_column :agents, :last_name, :string
    add_column :agents, :has_logged_in, :boolean, default: false
    add_column :agents, :last_webhook_update_received_at, :datetime
    up_only { Agent.update_all(has_logged_in: true) }

    add_index "agents", ["rdv_solidarites_agent_id"], unique: true
  end
end
