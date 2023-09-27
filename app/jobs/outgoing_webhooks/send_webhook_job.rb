module OutgoingWebhooks
  class OutgoingWebhookError < StandardError; end

  class SendWebhookJob < ApplicationJob
    def perform(webhook_endpoint_id, webhook_payload)
      @webhook_endpoint = WebhookEndpoint.find(webhook_endpoint_id)
      @webhook_payload = webhook_payload.deep_symbolize_keys

      send_webhook!
    end

    private

    def secret = @webhook_endpoint.secret

    def send_webhook!
      return if send_webhook.success?

      raise OutgoingWebhookError, send_webhook.errors unless send_webhook.success?
    end

    def send_webhook
      @send_webhook ||= OutgoingWebhooks::SendWebhook.call(
        webhook_endpoint: @webhook_endpoint,
        webhook_payload: @webhook_payload,
        webhook_signature: webhook_signature
      )
    end

    def webhook_signature
      case @webhook_endpoint.signature_type
      when "jwt"
        jwt_signature
      when "hmac"
        hmac_signature
      end
    end

    def jwt_signature
      resource_klass = @webhook_payload.dig(:meta, :model).safe_constantize
      unless resource_klass.respond_to?(:jwt_payload_keys)
        raise OutgoingWebhookError, "JWT signature impossible for #{resource_klass}"
      end

      jwt = JWT.encode(
        @webhook_payload[:data].slice(*resource_klass.jwt_payload_keys),
        secret, "HS256", { typ: "JWT", exp: 10.minutes.from_now.to_i }
      )

      { "Authorization" => "Bearer #{jwt}" }
    end

    def hmac_signature
      { "X-RDVI-SIGNATURE" => OpenSSL::HMAC.hexdigest("SHA256", secret, @webhook_payload.to_json) }
    end
  end
end
