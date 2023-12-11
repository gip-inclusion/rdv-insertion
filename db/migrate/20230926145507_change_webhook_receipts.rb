class ChangeWebhookReceipts < ActiveRecord::Migration[7.0]
  def change
    add_column :webhook_receipts, :resource_model, :string

    remove_index :webhook_receipts, :rdv_solidarites_rdv_id

    rename_column :webhook_receipts, :rdv_solidarites_rdv_id, :resource_id
    rename_column :webhook_receipts, :rdvs_webhook_timestamp, :timestamp

    remove_column :webhook_receipts, :sent_at, :datetime

    up_only { WebhookReceipt.update_all(resource_model: "Rdv") }
  end
end
