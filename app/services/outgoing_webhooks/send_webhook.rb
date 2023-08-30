module OutgoingWebhooks
  class SendWebhook < BaseService
    def initialize(webhook_endpoint, webhook_payload, webhook_signature)
      @webhook_endpoint = webhook_endpoint
      @webhook_payload = webhook_payload.deep_symbolize_keys
      @webhook_signature = webhook_signature
    end

    def call
      ActiveRecord::Base
        .with_advisory_lock("send_#{resource_name}_#{resource_id}_to_endpoint_#{@webhook_endpoint_id}") do
        return if old_update?

        send_webhook
        create_webhook_receipt
      end
    end

    private

    def resource_id
      @webhook_payload[:data][:id]
    end

    def resouce_model
      @webhook_payload[:meta][:model]
    end

    def webhook_timestamp
      @webhook_payload[:meta][:timestamp].to_datetime
    end

    def send_webhook
      response = Faraday.post(
        webhook_endpoint.url,
        @webhook_payload.to_json,
        request_headers
      )
      fail!(error_message_for(response)) unless response.success?
    end

    def request_headers
      {
        "Content-Type" => "application/json",
        "Accept" => "application/json"
      }.merge(@webhook_signature)
    end

    def old_update?
      last_webhook_receipt_for_resource.present? && webhook_timestamp < last_webhook_receipt_for_resource.timestamp
    end

    def last_webhook_receipt_for_resource
      @last_webhook_receipt_for_resource ||= WebhookReceipt.where(
        webhook_endpoint_id: @webhook_endpoint_id, resouce_model:, resource_id:
      ).order(timestamp: :desc).first
    end

    def create_webhook_receipt
      webhook_receipt = WebhookReceipt.new(
        webhook_endpoint_id: @webhook_endpoint_id, resouce_model:, resource_id:
      )
      return if webhook_receipt.save

      Sentry.capture_exception("Webhook receipt with attributes #{webhook_receipt.attributes} could not be created.")
    end

    def error_message_for(response)
      "Could not send webhook to url #{webhook_endpoint.url}\n" \
        "resource model: #{resouce_model}\n" \
        "resource id: #{resource_id}\n" \
        "response status: #{response.status}\n" \
        "response body: #{response.body.force_encoding('UTF-8')[0...1000]}"
    end
  end
end
