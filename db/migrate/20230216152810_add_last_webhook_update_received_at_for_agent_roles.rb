class AddLastWebhookUpdateReceivedAtForAgentRoles < ActiveRecord::Migration[7.0]
  def change
    add_column :agent_roles, :last_webhook_update_received_at, :datetime
  end
end
