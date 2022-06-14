module HasMotifCategoryConcern
  extend ActiveSupport::Concern

  MOTIF_CATEGORIES_NAMES_MAPPING = {
    "rsa_orientation" => "RSA orientation",
    "rsa_accompagnement" => "RSA accompagnement",
    "rsa_orientation_on_phone_platform" => "RSA orientation sur plateforme téléphonique"
  }.freeze

  included do
    enum motif_category: { rsa_orientation: 0, rsa_accompagnement: 1, rsa_orientation_on_phone_platform: 2 }
  end

  def motif_category_human
    MOTIF_CATEGORIES_NAMES_MAPPING[motif_category]
  end
end
