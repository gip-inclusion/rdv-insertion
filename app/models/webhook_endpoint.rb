class WebhookEndpoint < ApplicationRecord
  has_and_belongs_to_many :organisations

  enum signature_type: { hmac: 0, jwt: 1 }
end
