class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  include Serializable

  def self.squishes(*attributes)
    attributes.each do |attribute|
      class_eval { normalizes attribute, with: ->(a) { a.squish } }
    end
  end

  def self.nullify_blank(*attributes)
    attributes.each do |attribute|
      class_eval { normalizes attribute, with: ->(a) { a.presence } }
    end
  end

  def self.symbolized_attribute_names = attribute_names.map(&:to_sym)

  def symbolized_attributes = attributes.deep_symbolize_keys
end