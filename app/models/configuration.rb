class Configuration < ApplicationRecord
  has_many :organisations, dependent: :nullify
end
