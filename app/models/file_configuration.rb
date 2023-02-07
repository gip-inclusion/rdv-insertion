class FileConfiguration < ApplicationRecord
  has_many :organisations, dependent: :restrict_with_error

  validates :column_names, uniqueness: { scope: :sheet_name }
end
