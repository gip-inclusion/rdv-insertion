module Sanitizeable
  extend ActiveSupport::Concern

  included do
    before_save :sanitize_attributes
  end

  private

  def sanitize_attributes
    changed_attributes.each_key do |attr|
      self[attr] = sanitize_value(self[attr])
    end
  end

  def sanitize_value(value)
    case value
    when String
      sanitize_string(value)
    when Array
      value.map { |v| sanitize_value(v) }
    when Hash
      value.transform_values { |v| sanitize_value(v) }
    else
      value
    end
  end

  def sanitize_string(value)
    return value unless value.is_a?(String)

    partially_sanitized_value = value.gsub("\r", "").gsub(" ", " ")
    sanitized_value = ActionView::Base.full_sanitizer.sanitize(partially_sanitized_value)
    fully_sanitized_value = CGI.unescapeHTML(sanitized_value)

    return value if partially_sanitized_value == fully_sanitized_value

    Sentry.capture_message(
      "Potential XSS attempt on #{self.class.name}",
      extra: {
        id:,
        original_value: value,
        sanitized_value: fully_sanitized_value
      }
    )

    fully_sanitized_value
  end
end
