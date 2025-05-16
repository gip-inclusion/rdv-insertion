class Delivery < ApplicationRecord
  delegated_type :delivery_method, types: %w[
    Delivery::BySms
    Delivery::ByEmail
    Delivery::ByLetter
  ], dependent: :destroy

  scope :by_sms,    -> { where(delivery_method_type: "Delivery::BySms") }
  scope :by_email,  -> { where(delivery_method_type: "Delivery::ByEmail") }
  scope :by_letter, -> { where(delivery_method_type: "Delivery::ByLetter") }

  belongs_to :sendable, polymorphic: true

  validates :delivery_method, presence: true

  accepts_nested_attributes_for :delivery_method

  def sms? = delivery_method_type == "Delivery::BySms"
  def email?  = delivery_method_type == "Delivery::ByEmail"
  def letter? = delivery_method_type == "Delivery::ByLetter"

  class << self
    def build_with_delivery_method(channel:)
      new(delivery_method: "Delivery::By#{channel.to_s.capitalize}".constantize.new)
    end
  end
end
