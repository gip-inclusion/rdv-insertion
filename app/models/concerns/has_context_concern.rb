module HasContextConcern
  extend ActiveSupport::Concern

  CONTEXT_NAMES_MAPPING = {
    "rsa_orientation" => "RSA orientation",
    "rsa_accompagnement" => "RSA accompagnement"
  }.freeze

  included do
    enum context: { rsa_orientation: 0, rsa_accompagnement: 1 }
  end

  def context_name
    CONTEXT_NAMES_MAPPING[context]
  end
end
