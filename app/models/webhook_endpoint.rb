class WebhookEndpoint < ApplicationRecord
  belongs_to :organisation
  has_and_belongs_to_many :organisations

  enum signature_type: { hmac: "hmac", jwt: "jwt" }
end
