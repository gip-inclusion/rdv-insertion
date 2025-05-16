module ActsAsDeliveryMethod
  extend ActiveSupport::Concern

  included do
    has_one :delivery, as: :delivery_method, dependent: :destroy
    validates :delivery, presence: true
  end
end
