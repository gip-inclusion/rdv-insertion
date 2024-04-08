class WebhookEndpoint < ApplicationRecord
  has_and_belongs_to_many :organisations

  enum signature_type: { hmac: "hmac", jwt: "jwt" }
end
