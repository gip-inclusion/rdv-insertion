module Webhooks
  module ReceiptHandler
    def with_webhook_receipt(resource_model:, resource_id:, timestamp:, webhook_endpoint_id: nil)
      # france travail webhooks are not linked to a webhook_endpoint
      return if old_update?(resource_model: resource_model, resource_id: resource_id, timestamp: timestamp,
                            webhook_endpoint_id: webhook_endpoint_id)

      yield if block_given?

      create_webhook_receipt(resource_model: resource_model, resource_id: resource_id, timestamp: timestamp,
                             webhook_endpoint_id: webhook_endpoint_id)
    end

    private

    def old_update?(resource_model:, resource_id:, timestamp:, webhook_endpoint_id: nil)
      last_receipt = last_webhook_receipt_for_resource(resource_model, resource_id, webhook_endpoint_id)
      last_receipt.present? && timestamp <= last_receipt.timestamp
    end

    def last_webhook_receipt_for_resource(resource_model, resource_id, webhook_endpoint_id)
      WebhookReceipt.where(
        resource_model: resource_model,
        resource_id: resource_id,
        webhook_endpoint_id: webhook_endpoint_id
      ).order(timestamp: :desc).first
    end

    def create_webhook_receipt(resource_model:, resource_id:, timestamp:, webhook_endpoint_id: nil)
      webhook_receipt = WebhookReceipt.new(
        resource_model: resource_model,
        resource_id: resource_id,
        timestamp: timestamp,
        webhook_endpoint_id: webhook_endpoint_id
      )
      return if webhook_receipt.save

      Sentry.capture_message("Webhook receipt with attributes #{webhook_receipt.attributes} could not be created.")
    end
  end
end
