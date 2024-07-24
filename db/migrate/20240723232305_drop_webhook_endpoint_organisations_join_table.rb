class DropWebhookEndpointOrganisationsJoinTable < ActiveRecord::Migration[7.1]
  # rubocop:disable Metrics/AbcSize
  def change
    up_only do
      ## updating existing receipts
      WebhookEndpoint.where(organisation_id: nil).find_each do |webhook_endpoint|
        WebhookReceipt.where(webhook_endpoint_id: webhook_endpoint.id).find_each do |webhook_receipt|
          organisation_id = if webhook_receipt.resource_model == "Rdv"
                              Rdv.find_by(id: webhook_receipt.resource_id)&.organisation_id
                            end

          new_webhook_endpoint = if organisation_id
                                   WebhookEndpoint.find_by(organisation_id:)
                                 else
                                   WebhookEndpoint.find_by(old_webhook_endpoint_id: webhook_endpoint.id)
                                 end
          webhook_receipt.webhook_endpoint_id = new_webhook_endpoint.id
          webhook_receipt.save!
        end

        ## destroying webhook endpoint
        webhook_endpoint.destroy!
      end
    end

    remove_column :webhook_endpoints, :old_webhook_endpoint_id, :integer

    drop_join_table :webhook_endpoints, :organisations
  end
  # rubocop:enable Metrics/AbcSize
end
