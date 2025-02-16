class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  include Serializable

  def self.first
    if column_for_attribute(:id) == :uuid
      order(created_at: :asc).first
    else
      super
    end
  end

  def self.last
    if column_for_attribute(:id) == :uuid
      order(created_at: :desc).first
    else
      super
    end
  end

  def self.squishes(*attributes)
    attributes.each do |attribute|
      normalizes attribute, with: ->(a) { a.squish }
    end
  end

  def self.nullify_blank(*attributes)
    attributes.each do |attribute|
      normalizes attribute, with: ->(a) { a.presence }
    end
  end

  def self.symbolized_attribute_names = attribute_names.map(&:to_sym)

  def symbolized_attributes = attributes.deep_symbolize_keys
end
