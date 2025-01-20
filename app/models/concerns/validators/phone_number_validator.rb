class PhoneNumberValidator < ActiveModel::EachValidator
  def validate_each(record, _attribute, value)
    return if value.blank?

    is_valid_regular_phone_number = PhoneNumberHelper.parsed_number(value).present?
    is_valid_short_phone_number = options[:allow_4_digits_numbers] && value.match(/^\d{4}$/)

    return if is_valid_regular_phone_number || is_valid_short_phone_number

    record.errors.add(:phone_number, :invalid)
  end
end
