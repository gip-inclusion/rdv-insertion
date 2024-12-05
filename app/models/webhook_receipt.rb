class WebhookReceipt < ApplicationRecord
  belongs_to :webhook_endpoint, optional: true

  validates :resource_model, :resource_id, :timestamp, presence: true
end
