module HasContextConcern
  extend ActiveSupport::Concern

  CONTEXT_NAMES_MAPPING = {
    "rsa_orientation" => "RSA orientation",
    "rsa_accompagnement" => "RSA accompagnement",
    "rsa_orientation_phone_platform" => "RSA orientation sur plateforme téléphonique"
  }.freeze

  included do
    enum context: { rsa_orientation: 0, rsa_accompagnement: 1, rsa_orientation_phone_platform: 2 }
  end

  def context_name
    CONTEXT_NAMES_MAPPING[context]
  end
end
