class AcceptedFormatsValidatorError < StandardError; end

class AcceptedFormatsValidator < ActiveModel::EachValidator
  def validate_each(record, _attribute, value)
    verify_options!(options)

    return if value.blob.blank? || options[:mime_types].include?(value.blob.content_type)

    record.errors.add(:base, "Seuls les formats #{options[:formats].join(', ')} sont acceptés.")
  end

  private

  def verify_options!(options)
    return if options.key?(:formats) && options[:formats].is_a?(Array) &&
              options.key?(:mime_types) && options[:mime_types].is_a?(Array)

    raise AcceptedFormatsValidatorError, "options[:formats] and options[:mime_types] must be defined and be arrays"
  end
end
