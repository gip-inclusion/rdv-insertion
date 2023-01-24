module HasMotifCategory
  extend ActiveSupport::Concern

  ATELIERS = %w[rsa_insertion_offer rsa_atelier_competences rsa_atelier_rencontres_pro].freeze

  included do
    enum motif_category: Motif::CATEGORIES_ENUM
    scope :not_atelier, -> { where.not(motif_category: ATELIERS) }
  end

  def motif_category_human
    I18n.t("activerecord.attributes.motif.categories.#{motif_category}")
  end

  def atelier?
    motif_category.in?(ATELIERS)
  end

  def phone_platform?
    motif_category == "rsa_orientation_on_phone_platform"
  end
end
