class Configuration < ApplicationRecord
  include HasMotifCategoryConcern

  has_and_belongs_to_many :organisations
end
