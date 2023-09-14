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

  def send_webhoook_with_jwt_signature!(webhook_endpoint, webhook_payload, jwt_payload_keys)
    send_webhook!(
      webhook_endpoint,
      webhook_signature,
      JwtSignature.new(webhook_payload.slice(*jwt_payload_keys), webhook_endpoint.secret).to_h
    )
  end
end
