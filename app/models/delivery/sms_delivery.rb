class Delivery::SmsDelivery < ApplicationRecord
  include Delivery::Channel
  include Delivery::Status

  enum :provider, { brevo: "brevo", primotext: "primotexto" }

  validates :provider, presence: true
end
