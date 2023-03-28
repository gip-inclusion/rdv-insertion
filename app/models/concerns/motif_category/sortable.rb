module MotifCategory::Sortable
  CHRONOLOGICALLY_SORTED_CATEGORIES_SHORT_NAMES = %w[
    rsa_integration_information
    rsa_orientation
    rsa_orientation_on_phone_platform
    rsa_accompagnement
    rsa_accompagnement_social
    rsa_accompagnement_sociopro
    rsa_follow_up
    rsa_cer_signature
    rsa_insertion_offer
    rsa_atelier_competences
    rsa_atelier_rencontres_pro
    rsa_atelier_collectif_mandatory
    rsa_main_tendue
    rsa_spie
    psychologue
  ].freeze

  def position
    CHRONOLOGICALLY_SORTED_CATEGORIES_SHORT_NAMES.index(short_name) ||
      (CHRONOLOGICALLY_SORTED_CATEGORIES_SHORT_NAMES.length + 1)
  end
end
