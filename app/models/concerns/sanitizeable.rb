module Sanitizeable
  extend ActiveSupport::Concern

  class_methods do
    def sanitize(*columns)
      before_save do
        columns.each do |column|
          self[column] = ActionView::Base.full_sanitizer.sanitize(self[column]) if self[column].present?
        end
      end
    end
  end
end
