class MotifCategory < ApplicationRecord
  SHARED_ATTRIBUTES_WITH_RDV_SOLIDARITES = [
    :name, :short_name
  ].freeze

  MOTIF_CATEGORY_TYPES_SORTED = %w[rsa_orientation rsa_accompagnement siae autre].freeze
  RSA_RELATED_TYPES = %w[rsa_orientation rsa_accompagnement].freeze

  has_many :category_configurations, dependent: :restrict_with_exception
  has_many :follow_ups, dependent: :restrict_with_exception
  has_many :motifs, dependent: :restrict_with_exception
  belongs_to :template

  validates :short_name, presence: true, uniqueness: true
  validates :name, presence: true
  validates :motif_category_type, presence: true
  validates :rdv_solidarites_motif_category_id, uniqueness: true, allow_nil: true

  delegate :model, to: :template, prefix: true
  delegate :atelier?, to: :template

  enum :motif_category_type, MOTIF_CATEGORY_TYPES_SORTED.index_by(&:itself)

  scope :grouped_by_type, -> { group_by(&:motif_category_type).slice(*MOTIF_CATEGORY_TYPES_SORTED) }
end
