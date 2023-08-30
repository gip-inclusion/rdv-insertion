class AddAttributesToWebhookReceipts < ActiveRecord::Migration[7.0]
  def change
    rename_column :webhook_receipts, :rdv_solidarites_rdv_id, :resource_id
    add_column :webhook_receipts, :resource_model, :string

    up_only { WebhookReceipt.update_all(resource_model: "Rdv") }
  end
end
