class WebhookEndpoint < ApplicationRecord
  has_and_belongs_to_many :organisations
end
