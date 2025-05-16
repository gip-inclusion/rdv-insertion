class Delivery::BySms < ApplicationRecord
  self.table_name = "sms_deliveries"

  include ActsAsDeliveryMethod
  include DeliveryStatus

  enum :provider, { brevo: "brevo", primotexto: "primotexto" }

  validates :provider, presence: true
end
