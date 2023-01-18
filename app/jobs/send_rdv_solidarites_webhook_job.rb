class OutgoingWebhookError < StandardError; end

class SendRdvSolidaritesWebhookJob < ApplicationJob
  JWT_PAYLOAD_KEYS = [:id, :address, :starts_at].freeze

  def perform(webhook_endpoint_id, webhook_payload)
    @webhook_endpoint_id = webhook_endpoint_id
    @webhook_payload = webhook_payload.deep_symbolize_keys

    ActiveRecord::Base.with_advisory_lock("send_rdv_#{rdv_solidarites_rdv_id}_to_endpoint_#{@webhook_endpoint_id}") do
      return if old_update?

      send_webhook
      add_timestamps_to_receipt
    end
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

  def old_update?
    webhook_receipt.persisted? && webhook_timestamp < webhook_receipt.rdvs_webhook_timestamp
  end

  def webhook_receipt
    @webhook_receipt ||= WebhookReceipt.find_or_initialize_by(
      webhook_endpoint_id: @webhook_endpoint_id,
      rdv_solidarites_rdv_id: rdv_solidarites_rdv_id
    )
  end

  def add_timestamps_to_receipt
    webhook_receipt.update!(rdvs_webhook_timestamp: webhook_timestamp, sent_at: Time.zone.now)
  end

  def error_message_for(response)
    "Could not send webhook to url #{webhook_endpoint.url}\n" \
      "rdv solidarites rdv id: #{rdv_solidarites_rdv_id}\n" \
      "response status: #{response.status}\n" \
      "response body: #{response.body.force_encoding('UTF-8')[0...1000]}"
  end

  def webhook_endpoint
    @webhook_endpoint ||= WebhookEndpoint.find(@webhook_endpoint_id)
  end

  def rdv_solidarites_rdv_id
    @webhook_payload[:data][:id]
  end

  def webhook_timestamp
    @webhook_payload[:meta][:timestamp].to_datetime
  end

  def request_headers
    {
      "Content-Type" => "application/json",
      "Accept" => "application/json",
      "Authorization" => "Bearer #{generated_jwt}"
    }
  end

  def generated_jwt
    JWT.encode(jwt_payload, webhook_endpoint.secret, "HS256", { typ: "JWT", exp: 10.minutes.from_now.to_i })
  end

  def jwt_payload
    # See https://pad.incubateur.net/s/3lA9V4g5Q#Headers
    @webhook_payload[:data].slice(*JWT_PAYLOAD_KEYS)
  end
end
