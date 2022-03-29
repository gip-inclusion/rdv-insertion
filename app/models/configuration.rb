class Configuration < ApplicationRecord
  has_and_belongs_to_many :organisations

  enum context: { rsa_orientation: 0, rsa_accompagnement: 1 }
end
