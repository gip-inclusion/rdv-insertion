class MotifCategory < ApplicationRecord
  include MotifCategory::Sortable

  has_many :configurations, dependent: :restrict_with_exception
  has_many :rdv_contexts, dependent: :restrict_with_exception
  has_many :motifs, dependent: :restrict_with_exception
  belongs_to :template

  validates :short_name, presence: true, uniqueness: true
  validates :name, presence: true
  validates :rdv_solidarites_motif_category_id, uniqueness: true, allow_nil: true

  delegate :model, to: :template, prefix: true
  delegate :atelier?, to: :template

  CATEGORIES_NOT_MANDATORY_SHORT_NAMES = %w[
    rsa_insertion_offer rsa_atelier_competences rsa_atelier_rencontres_pro
  ].freeze

  scope :rdvs_mandatory, -> { where.not(short_name: CATEGORIES_NOT_MANDATORY_SHORT_NAMES) }

  def rdvs_mandatory?
    !short_name.in?(CATEGORIES_NOT_MANDATORY_SHORT_NAMES)
  end
end
