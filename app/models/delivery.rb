class Delivery < ApplicationRecord
  delegated_type :delivery_channel, types: %w[
    Delivery::SmsDelivery
    Delivery::EmailDelivery
    Delivery::PostalDelivery
  ], dependent: :destroy

  scope :sms,    -> { where(delivery_channel_type: "Delivery::SmsDelivery") }
  scope :email,  -> { where(delivery_channel_type: "Delivery::EmailDelivery") }
  scope :postal, -> { where(delivery_channel_type: "Delivery::PostalDelivery") }

  belongs_to :deliverable, polymorphic: true

  validates :delivery_channel, presence: true

  # Returns "sms", "email", or "postal"
  def channel
    delivery_channel_type.demodulize.sub("Delivery", "").underscore
  end
end
