class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  include Serializable

  def self.squish_normalizes(*attributes)
    attributes.each do |attribute|
      class_eval { normalizes attribute, with: ->(a) { a.squish } }
    end
  end
end
