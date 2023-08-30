module OutgoingWebhooks
  extend ActiveSupport::Concern

  private

  def send_webhook!(webhook_endpoint, webhook_payload, webhook_signature)
    result = send_webhook(webhook_endpoint, webhook_payload, webhook_signature)

    raise OutgoingWebhookError, result.errors unless result.success?
  end

  def send_webhook(webhook_endpoint, webhook_payload, webhook_signature)
    OutgoingWebhooks::SendWebhook.call(
      webhook_endpoint: webhook_endpoint,
      webhook_payload: webhook_payload,
      webhook_signature: webhook_signature
    )
  end

  def generate_signature_from_jwt(jwt)
    { "Authorization" => "Bearer #{jwt}" }
  end
end
