class Configuration < ApplicationRecord
  include MotifCategorizable

  has_many :configurations_organisations, dependent: :destroy
  has_many :organisations, through: :configurations_organisations
end
