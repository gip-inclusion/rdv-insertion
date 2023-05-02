# Concern to include in application models
# Models need to have a :phone_number and a :phone_number_formatted attributes
module PhoneNumberValidation
  extend ActiveSupport::Concern
  include PhoneNumberFormatter

  included do
    validate :phone_number_is_valid
  end

  def phone_number_formatted
    format_phone_number(phone_number)
  end

  def phone_number_is_mobile?
    types = parsed_number(phone_number)&.types
    types&.include?(:mobile)
  end

  private

  def phone_number_is_valid
    return if phone_number.blank?

    errors.add(:phone_number, :invalid) unless phone_number_is_valid?
  end

  def phone_number_is_mobile
    return if phone_number.blank?

    errors.add(:phone_number, :invalid) unless phone_number_is_valid?
  end

  def phone_number_is_valid?
    parsed_number(phone_number).present?
  end
end
