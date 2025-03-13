module Sanitizeable
  extend ActiveSupport::Concern

  included do
    before_save :sanitize_attributes
  end

  private

  def sanitize_attributes
    changed_attributes.each_key do |attr|
      original_value = self[attr]
      next unless original_value.is_a?(String)

      sanitized_value = ActionView::Base.full_sanitizer.sanitize(self[attr])

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
end
