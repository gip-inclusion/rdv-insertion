class OutgoingWebhookError < StandardError; end

class SendRdvSolidaritesWebhookJob < ApplicationJob
  JWT_PAYLOAD_KEYS = [:id, :address, :starts_at].freeze

  def perform(webhook_endpoint_id, webhook_payload)
    @webhook_endpoint_id = webhook_endpoint_id
    @webhook_payload = webhook_payload.deep_symbolize_keys

    send_webhook
  end

  private

  def send_webhook
    response = Faraday.post(
      webhook_endpoint.url,
      @webhook_payload.to_json,
      request_headers
    )
    raise OutgoingWebhookError, error_message_for(response) unless response.success?
  end

  def error_message_for(response)
    "Could not send webhook to url #{webhook_endpoint.url}\n" \
      "rdv solidarites rdv id: #{@webhook_payload[:data][:id]}\n" \
      "response status: #{response.status}\n" \
      "response body: #{response.body.force_encoding('UTF-8')[0...1000]}"
  end

  def webhook_endpoint
    @webhook_endpoint ||= WebhookEndpoint.find(@webhook_endpoint_id)
  end

  def request_headers
    {
      "Content-Type" => "application/json",
      "Accept" => "application/json",
      "Authorization" => "Bearer #{generated_jwt}"
    }
  end

  def generated_jwt
    JWT.encode(jwt_payload, webhook_endpoint.secret, 'HS256', { typ: "JWT", exp: 10.minutes.from_now.to_i })
  end

  def jwt_payload
    # See https://pad.incubateur.net/s/3lA9V4g5Q#Headers
    @webhook_payload[:data].slice(*JWT_PAYLOAD_KEYS)
  end
end
