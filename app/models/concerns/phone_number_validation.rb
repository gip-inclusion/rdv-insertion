module PhoneNumberValidation
  extend ActiveSupport::Concern

  included do
    validate :phone_number_is_valid
  end

  def phone_number_is_mobile?
    types = PhoneNumberHelper.parsed_number(phone_number)&.types
    types&.include?(:mobile)
  end

  private

  def phone_number_is_valid
    return if phone_number.blank?

    errors.add(:phone_number, :invalid) unless phone_number_is_valid?
  end

  def phone_number_is_valid?
    PhoneNumberHelper.parsed_number(phone_number).present?
  end
end
