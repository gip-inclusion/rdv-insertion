class RenameDeliveredAtToLastBrevoWebhookReceivedAt < ActiveRecord::Migration[7.1]
  def change
    rename_column :notifications, :delivered_at, :last_brevo_webhook_received_at
    rename_column :invitations, :delivered_at, :last_brevo_webhook_received_at
  end
end
