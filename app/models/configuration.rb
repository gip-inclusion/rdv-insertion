class Configuration < ApplicationRecord
  include HasContextConcern

  has_and_belongs_to_many :organisations
end
