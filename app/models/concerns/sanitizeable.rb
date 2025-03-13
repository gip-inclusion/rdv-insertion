module Sanitizeable
  extend ActiveSupport::Concern

  included do
    before_save do
      attributes.each do |attr, value|
        self[attr] = ActionView::Base.full_sanitizer.sanitize(value) if value.is_a?(String)

        next if value == self[attr]

        Sentry.capture_message("Potential XSS attempt on #{self.class.name}", extra: { id:, value: })
      end
    end
  end
end
