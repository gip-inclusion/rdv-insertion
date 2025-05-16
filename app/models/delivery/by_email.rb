class Delivery::ByEmail < ApplicationRecord
  self.table_name = "email_deliveries"

  include ActsAsDeliveryMethod
  include DeliveryStatus

  enum :provider, { brevo: "brevo" }
  validates :provider, presence: true
end
