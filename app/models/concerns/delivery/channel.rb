module Delivery::Channel
  extend ActiveSupport::Concern

  included do
    has_one :delivery, as: :delivery_channel, inverse_of: :delivery_channel, dependent: :destroy
    validates :delivery, presence: true
  end
end
