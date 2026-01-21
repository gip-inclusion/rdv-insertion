module WebhookDeliverable
  extend ActiveSupport::Concern

  included do
    attr_accessor :should_send_webhook

    after_commit on: :create, if: :should_send_webhook? do
      generate_payload_and_send_webhook(:created)
    end

    after_commit on: :update, if: :should_send_webhook? do
      generate_payload_and_send_webhook(:updated)
    end

    around_destroy :generate_payload_and_send_webhook_for_destroy, if: :should_send_webhook?
  end

  def generate_payload_and_send_webhook(action)
    subscribed_webhook_endpoints.each do |endpoint|
      # we need to precise the organisation type since the webhook payload can be
      # different depending on organisation_type
      payload = generate_webhook_payload(action, endpoint.organisation_type)
      OutgoingWebhooks::SendWebhookJob.perform_later(endpoint.id, payload)
    end
  end

  def generate_webhook_payload(action, organisation_type)
    {
      data: as_json(organisation_type:),
      meta: {
        model: self.class.name,
        event: action,
        timestamp: Time.zone.now
      }
    }
  end

  def generate_payload_and_send_webhook_for_destroy
    # Prépare les données à envoyer, avant de supprimer l'objet
    payloads = subscribed_webhook_endpoints.index_with do |endpoint|
      generate_webhook_payload(:destroyed, endpoint.organisation_type)
    end
    # Execute la suppression, après avoir construit les données à envoyer
    result = yield if block_given?
    return if result == false

    payloads.each do |endpoint, payload|
      OutgoingWebhooks::SendWebhookJob.perform_later(endpoint.id, payload)
    end
  end

  def subscribed_webhook_endpoints
    webhook_endpoints.select { it.subscriptions.include?(self.class.name.underscore) }
  end

  def should_send_webhook?
    return true if @should_send_webhook.nil?

    @should_send_webhook
  end
end
