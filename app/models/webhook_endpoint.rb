class WebhookEndpoint < ApplicationRecord
  belongs_to :organisation

  validates :url, :secret, :signature_type, presence: true
  validates :url, uniqueness: { scope: :organisation_id }

  enum :signature_type, { hmac: "hmac", jwt: "jwt" }

  delegate :organisation_type, to: :organisation
end
