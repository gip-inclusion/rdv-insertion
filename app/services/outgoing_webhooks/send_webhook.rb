module OutgoingWebhooks
  class SendWebhook < BaseService
    include Webhook::ReceiptHandler

    def initialize(webhook_endpoint:, webhook_payload:, webhook_signature:)
      @webhook_endpoint = webhook_endpoint
      @webhook_payload = webhook_payload.deep_symbolize_keys
      @webhook_signature = webhook_signature
    end

    def call
      ActiveRecord::Base
        .with_advisory_lock("send_#{resource_model}_#{resource_id}_to_endpoint_#{@webhook_endpoint.id}") do
        with_webhook_receipt(
          resource_model: resource_model,
          resource_id: resource_id,
          timestamp: timestamp,
          webhook_endpoint_id: @webhook_endpoint.id
        ) do
          send_webhook
        end
      end
    end

    private

    def resource_id
      @webhook_payload[:data][:id]
    end

    def resource_model
      @webhook_payload[:meta][:model]
    end

    def timestamp
      @webhook_payload[:meta][:timestamp].to_datetime
    end

    def send_webhook
      response = Faraday.post(
        @webhook_endpoint.url,
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

    def error_message_for(response)
      "Could not send webhook to url #{@webhook_endpoint.url}\n" \
        "resource model: #{resource_model}\n" \
        "resource id: #{resource_id}\n" \
        "response status: #{response.status}\n" \
        "response body: #{response.body.force_encoding('UTF-8')[0...1000]}"
    end
  end
end
