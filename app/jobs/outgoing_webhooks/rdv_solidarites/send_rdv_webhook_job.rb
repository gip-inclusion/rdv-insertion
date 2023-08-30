module OutgoingWebhooks
  module RdvSolidarites
    class SendRdvWebhookJob < ApplicationJob
      include OutgoingWebhooks

      JWT_PAYLOAD_KEYS = [:id, :address, :starts_at].freeze

      def perform(webhook_endpoint_id, webhook_payload)
        @webhook_endpoint = WebhookEndpoint.find(webhook_endpoint_id)
        @webhook_signature = JwtSignature.new(
          payload: webhook_payload.slice(*JWT_PAYLOAD_KEYS), secret: webhook_endpoint.secret
        ).to_h
        send_webhook!(webhook_endpoint, webhook_payload, webhook_signature)
      end
    end
  end
end
