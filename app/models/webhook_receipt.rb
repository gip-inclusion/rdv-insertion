class WebhookReceipt < ApplicationRecord
  belongs_to :webhook_endpoint

  validates :rdv_solidarites_rdv_id, :sent_at, presence: true
end
