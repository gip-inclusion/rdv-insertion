class Configuration < ApplicationRecord
  include HasMotifCategory

  has_many :configurations_organisations, dependent: :destroy
  has_many :organisations, through: :configurations_organisations
end
