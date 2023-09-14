module OutgoingWebhooks
  class SendRdvWebhookJob < ApplicationJob
    include OutgoingWebhooks

    JWT_PAYLOAD_KEYS = [:id, :address, :starts_at].freeze

    def perform(webhook_endpoint_id, webhook_payload)
      webhook_endpoint = WebhookEndpoint.find(webhook_endpoint_id)
      send_webhoook_with_jwt_signature!(webhook_endpoint, webhook_payload, JWT_PAYLOAD_KEYS)
    end
  end
end
