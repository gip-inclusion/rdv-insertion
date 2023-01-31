class Configuration < ApplicationRecord
  belongs_to :motif_category
  has_many :configurations_organisations, dependent: :delete_all
  has_many :organisations, through: :configurations_organisations

  delegate :position, :name, to: :motif_category, prefix: true
end
