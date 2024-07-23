class WebhookEndpoint < ApplicationRecord
  belongs_to :organisation

  enum signature_type: { hmac: "hmac", jwt: "jwt" }
end
