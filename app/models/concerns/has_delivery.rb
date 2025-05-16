module HasDelivery
  extend ActiveSupport::Concern

  included do
    has_one :delivery, as: :sendable, dependent: :destroy
    validates :delivery, presence: true

    # Returns "sms", "email", or "postal"
    delegate :delivery_method, to: :delivery

    delegate :delivery_status, :provider, :delivered?,
             :delivery_failed?, :delivered_at, :delivery_date, :delivery_hour,
             :human_delivery_status_and_date,
             to: :delivery_method, allow_nil: true

    scope :with_delivery, -> { includes(delivery: :delivery_method) }

    scope :delivered_by_sms,    -> { joins(:delivery).merge(Delivery.by_sms) }
    scope :delivered_by_email,  -> { joins(:delivery).merge(Delivery.by_email) }
    scope :delivered_by_letter, -> { joins(:delivery).merge(Delivery.by_letter) }
  end

  class_methods do
    def build_with_delivery(channel:, **attributes)
      new(attributes).tap do |invitation|
        invitation.delivery = Delivery.build_with_delivery_method(channel:)
      end
    end
  end

  def delivered_by_sms?
    delivery.sms?
  end

  def delivered_by_email?
    delivery.email?
  end

  def delivered_by_letter?
    delivery.letter?
  end
end
