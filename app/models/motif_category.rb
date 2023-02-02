class MotifCategory < ApplicationRecord
  has_many :configurations, dependent: :restrict_with_exception
  has_many :rdv_contexts, dependent: :restrict_with_exception
  has_many :motifs, dependent: :restrict_with_exception
  belongs_to :template

  validates :short_name, presence: true, uniqueness: true
  validates :name, presence: true
  validates :rdv_solidarites_motif_category_id, uniqueness: true, allow_nil: true

  delegate :model, to: :template, prefix: true
  delegate :atelier?, to: :template

  CHRONOLOGICALLY_SORTED_CATEGORIES = %w[
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
  ].freeze

  scope :rdvs_mandatory, -> { where.not(template: Template.atelier) }

  def rdvs_mandatory?
    !atelier?
  end

  def position
    CHRONOLOGICALLY_SORTED_CATEGORIES.index(short_name) || (CHRONOLOGICALLY_SORTED_CATEGORIES.length + 1)
  end
end
