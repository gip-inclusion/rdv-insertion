class WebhookEndpoint < ApplicationRecord
  belongs_to :organisation

  validates :organisation_id, uniqueness: true

  enum :signature_type, { hmac: "hmac", jwt: "jwt" }

  delegate :organisation_type, to: :organisation
end
