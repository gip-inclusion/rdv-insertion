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
      OutgoingWebhooks::SendWebhookJob.perform_async(endpoint.id, generate_webhook_payload(action))
    end
  end

  def generate_webhook_payload(action)
    {
      data: as_json,
      meta: {
        model: self.class.name,
        event: action,
        timestamp: Time.zone.now
      }
    }
  end

  def generate_payload_and_send_webhook_for_destroy
    # Prépare les données à envoyer, avant de supprimer l'objet
    payloads = subscribed_webhook_endpoints.index_with do |_endpoint|
      generate_webhook_payload(:destroyed)
    end
    # Execute la suppression, après avoir construit les données à envoyer
    yield if block_given?
    payloads.each do |endpoint, payload|
      OutgoingWebhooks::SendWebhookJob.perform_async(endpoint.id, payload)
    end
  end

  def subscribed_webhook_endpoints
    webhook_endpoints.select { _1.subscriptions.include?(self.class.name.underscore) }
  end

  def should_send_webhook?
    return true if @should_send_webhook.nil?

    @should_send_webhook
  end
end
