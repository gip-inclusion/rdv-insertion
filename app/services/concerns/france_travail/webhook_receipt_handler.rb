module FranceTravail::WebhookReceiptHandler
  # Reutiliser le code pour les autres webhook ?
  def with_webhook_receipt(resource_model:, resource_id:, timestamp:)
    return if old_update?(resource_model: resource_model, resource_id: resource_id, timestamp: timestamp)

    yield if block_given?

    create_webhook_receipt(resource_model: resource_model, resource_id: resource_id, timestamp: timestamp)
  end

  private

  def old_update?(resource_model:, resource_id:, timestamp:)
    last_receipt = last_webhook_receipt_for_resource(resource_model, resource_id)
    last_receipt.present? && timestamp <= last_receipt.timestamp
  end

  def last_webhook_receipt_for_resource(resource_model, resource_id)
    WebhookReceipt.france_travail
                  .where(resource_model: resource_model, resource_id: resource_id)
                  .order(timestamp: :desc).first
  end

  def create_webhook_receipt(resource_model:, resource_id:, timestamp:)
    webhook_receipt = WebhookReceipt.new(
      resource_model: resource_model,
      resource_id: resource_id,
      timestamp: timestamp
    )
    return if webhook_receipt.save

    Sentry.capture_message("Webhook receipt with attributes #{webhook_receipt.attributes} could not be created.")
  end
end
