class Configuration < ApplicationRecord
  belongs_to :motif_category
  belongs_to :file_configuration
  has_many :configurations_organisations, dependent: :delete_all
  has_many :organisations, through: :configurations_organisations

  delegate :position, :name, to: :motif_category, prefix: true

  def as_json(opts = {})
    super.merge(
      # TODO: delegate these methods to file_configuration
      sheet_name: file_configuration.sheet_name,
      column_names: file_configuration.column_names
    )
  end
end
