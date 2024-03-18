class MaxSizeValidatorError < StandardError; end

class MaxSizeValidator < ActiveModel::EachValidator
  def validate_each(record, _attribute, value)
    verify_options!(options)

    return if value.blob.blank? || value.blob.byte_size < options[:with]

    # max_size must be in megabytes for the error message to be accurate
    record.errors.add(:base, "Le fichier est trop volumineux (#{options[:with].to_s[0...-6]} Mo maximum)")
  end

  def verify_options!(options)
    return if options.key?(:with) && options[:with].is_a?(Integer)

    raise MaxSizeValidatorError, "max_size must be defined as an integer"
  end
end
