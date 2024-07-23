class AddOrganisationReferenceToWebhookEndpoints < ActiveRecord::Migration[7.1]
  def up
    add_reference :webhook_endpoints, :organisation
    add_column :webhook_endpoints, :old_webhook_endpoint_id, :integer

    WebhookEndpoint.includes(:organisations).find_each do |webhook_endpoint|
      ## creating new endpoints
      webhook_endpoint.organisations.each do |organisation|
        new_webhook_endpoint = webhook_endpoint.dup
        new_webhook_endpoint.organisation_id = organisation.id
        new_webhook_endpoint.old_webhook_endpoint_id = webhook_endpoint.id
        new_webhook_endpoint.save!
      end
    end
  end

  def down
    WebhookEndpoint.where.not(organisation_id: nil).destroy_all

    remove_reference :webhook_endpoints, :organisation
    remove_column :webhook_endpoints, :old_webhook_endpoint_id
  end
end
