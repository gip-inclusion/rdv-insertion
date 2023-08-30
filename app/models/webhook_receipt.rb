class WebhookReceipt < ApplicationRecord
  belongs_to :webhook_endpoint

  validates :resource_name, :resource_id, :timestamp, presence: true
end
