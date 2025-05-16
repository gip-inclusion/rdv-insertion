class Delivery::EmailDelivery < ApplicationRecord
  include Delivery::Channel
  include Delivery::Status

  enum :provider, { brevo: "brevo" }

  validates :provider, presence: true
end
