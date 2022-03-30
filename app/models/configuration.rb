class Configuration < ApplicationRecord
  CONTEXT_NAMES_MAPPING = {
    "rsa_orientation" => "RDV d'orientation RSA",
    "rsa_accompagnement" => "RDV d'accompagnement"
  }.freeze

  has_and_belongs_to_many :organisations

  enum context: { rsa_orientation: 0, rsa_accompagnement: 1 }

  def context_name
    CONTEXT_NAMES_MAPPING[context]
  end
end
