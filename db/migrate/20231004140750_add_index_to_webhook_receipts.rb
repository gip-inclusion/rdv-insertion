class AddIndexToWebhookReceipts < ActiveRecord::Migration[7.0]
  def change
    add_index :webhook_receipts, [:resource_model, :resource_id, :webhook_endpoint_id],
              name: "index_on_webhook_endpoint_and_resource_model_and_id"
  end
end
