class AddWebhookTimeStamp < ActiveRecord::Migration[7.0]
  def change
    add_column :rdvs, :last_webhook_update_received_at, :datetime
    add_column :applicants, :last_webhook_update_received_at, :datetime
    add_column :organisations, :last_webhook_update_received_at, :datetime
  end
end
