module HasDelivery
  extend ActiveSupport::Concern

  included do
    has_one :delivery, as: :deliverable, dependent: :destroy
    validates :delivery, presence: true

    # Returns "sms", "email", or "postal"
    delegate :channel, :delivery_channel, to: :delivery

    delegate :delivered?, :delivery_failed?, :delivery_status,
             :delivered_at, :delivery_hour, :delivery_date,
             :human_delivery_status_and_date,
             to: :delivery_channel

    scope :preload_delivery, -> { preload(delivery: :delivery_channel) }

    scope :sms,    -> { joins(:delivery).merge(Delivery.sms) }
    scope :email,  -> { joins(:delivery).merge(Delivery.email) }
    scope :postal, -> { joins(:delivery).merge(Delivery.postal) }
  end
end
