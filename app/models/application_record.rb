class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  include Serializable

  def self.squishes(*attributes)
    attributes.each do |attribute|
      class_eval { normalizes attribute, with: ->(a) { a.squish } }
    end
  end

  def self.symbolized_attribute_names = attribute_names.map(&:to_sym)
end
