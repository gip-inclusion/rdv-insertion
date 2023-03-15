class FileConfiguration < ApplicationRecord
  has_many :configurations, dependent: :restrict_with_error

  validates :sheet_name, :last_name_column, :first_name_column, :title_column, presence: true
  validate :column_names_uniqueness

  # a hash with key-value pairs for all informed column_names
  def column_names
    column_names_array.map do |column_name|
      send(column_name).present? ? [column_name, send(column_name)] : nil
    end.compact.to_h
  end

  def column_names_array
    attribute_names.select { |attribute_name| attribute_name.end_with?("column") }
  end

  private

  def column_names_uniqueness
    return if column_names_values.compact_blank.uniq.length == column_names_values.compact_blank.length

    errors.add(:base, "Chaque colonne doit avoir un nom différent")
  end

  def column_names_values
    column_names_array.map do |column_name|
      send(column_name)
    end.compact
  end
end
