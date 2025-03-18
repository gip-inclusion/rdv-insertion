module Sanitizeable
  extend ActiveSupport::Concern

  included do
    before_save :sanitize_attributes
  end

  private

  def sanitize_attributes
    changed_attributes.each_key do |attr|
      original_value = self[attr]

      sanitized_value = sanitize_value(original_value)
      next if sanitized_value == original_value

      self[attr] = sanitized_value

      Sentry.capture_message(
        "Potential XSS attempt on #{self.class.name}",
        extra: {
          id:,
          attribute: attr,
          original_value:,
          sanitized_value:
        }
      )
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

    sanitized_value = ActionView::Base.full_sanitizer.sanitize(value)
    CGI.unescapeHTML(sanitized_value)
  end
end
