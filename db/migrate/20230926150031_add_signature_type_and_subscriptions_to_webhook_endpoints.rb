class AddSignatureTypeAndSubscriptionsToWebhookEndpoints < ActiveRecord::Migration[7.0]
  def change
    add_column :webhook_endpoints, :subscriptions, :string, array: true
    add_column :webhook_endpoints, :signature_type, :integer, default: 0

    up_only { WebhookEndpoint.update_all(signature_type: 1, subscriptions: ["rdv"]) }
  end
end
