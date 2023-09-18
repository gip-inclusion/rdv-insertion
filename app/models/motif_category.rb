class MotifCategory < ApplicationRecord
  include MotifCategory::Sortable

  ORIENTATION_CATEGORIES_SHORT_NAMES = %w[
    rsa_orientation
    rsa_orientation_on_phone_platform
    rsa_atelier_collectif_mandatory
    rsa_spie
    rsa_integration_information
    rsa_orientation_coaching
    rsa_orientation_freelance
    rsa_orientation_france_travail
    rsa_orientation_file_active
    rsa_droits_devoirs
    rsa_accompagnement
    rsa_accompagnement_social
    rsa_accompagnement_sociopro
    rsa_accompagnement_moins_de_30_ans
  ].freeze

  has_many :configurations, dependent: :restrict_with_exception
  has_many :rdv_contexts, dependent: :restrict_with_exception
  has_many :motifs, dependent: :restrict_with_exception
  belongs_to :template

  validates :short_name, presence: true, uniqueness: true
  validates :name, presence: true
  validates :rdv_solidarites_motif_category_id, uniqueness: true, allow_nil: true

  delegate :model, to: :template, prefix: true
  delegate :atelier?, to: :template

  scope :participation_optional, lambda { |participation_optional = true|
    where(participation_optional: participation_optional)
  }

  def orientation?
    ORIENTATION_CATEGORIES_SHORT_NAMES.include?(short_name)
  end

  def as_json(...) = super.deep_symbolize_keys.except(:rdv_solidarites_motif_category_id)
end
