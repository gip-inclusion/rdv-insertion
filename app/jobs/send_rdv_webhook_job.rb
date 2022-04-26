class OutgoingWebhookError < StandardError; end

class SendRdvWebhookJob < ApplicationJob
  JWT_PAYLOAD_KEYS = [:id, :first_name, :last_name].freeze

  def perform(webhook_endpoint_id, rdv_payload, applicant_ids, meta)
    @webhook_endpoint_id = webhook_endpoint_id
    @rdv_payload = rdv_payload.deep_symbolize_keys
    @applicant_ids = applicant_ids
    @meta = meta.deep_symbolize_keys

    send_webhook
  end

  private

  def send_webhook
    response = Faraday.post(
      webhook_endpoint.url,
      webhook_payload.to_json,
      request_headers
    )
    raise OutgoingWebhookError, error_message_for(response) unless response.success?
  end

  def error_message_for(response)
    "Could not send webhook to url #{webhook_endpoint.url}\n" \
      "rdv solidarites rdv id: #{@rdv_payload[:id]}\n" \
      "response status: #{response.status}\n" \
      "response body: #{response.body.force_encoding('UTF-8')[0...1000]}"
  end

  # See https://pad.incubateur.net/s/3lA9V4g5Q#Payload-de-la-requ%C3%AAte
  def webhook_payload
    @webhook_payload ||= begin
      payload = @rdv_payload
      payload.delete(:users)
      payload[:applicants] = applicants.map(&:payload)
      payload[:event] = @meta[:event]
      payload
    end
  end

  def applicants
    @applicants ||= Applicant.where(id: @applicant_ids)
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
    JWT.encode(jwt_payload, webhook_endpoint.secret, 'HS256')
  end

  def jwt_payload
    # See https://pad.incubateur.net/s/3lA9V4g5Q#Headers
    @applicants.first.payload.slice(*JWT_PAYLOAD_KEYS).merge(exp: 10.minutes.from_now.to_i)
  end
end
