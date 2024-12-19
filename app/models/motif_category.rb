class MotifCategory < ApplicationRecord
  SHARED_ATTRIBUTES_WITH_RDV_SOLIDARITES = [
    :name, :short_name
  ].freeze

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

  enum motif_category_type: { autre: "autre", siae: "siae", rsa_orientation: "rsa_orientation",
                              rsa_accompagnement: "rsa_accompagnement" }

  RSA_RELATED_TYPES = %w[rsa_orientation rsa_accompagnement].freeze

  scope :authorized_for_organisation, lambda { |organisation|
    if organisation.rsa_related?
      where(motif_category_type: RSA_RELATED_TYPES)
    else
      where(motif_category_type: organisation.organisation_type)
    end
  }

  # We need a dedicated method on top of the scope because we may be validating on a new object
  # which the scope is not yet aware of
  def authorized_for_organisation?(organisation)
    return RSA_RELATED_TYPES.include?(motif_category_type) if organisation.rsa_related?

    organisation.organisation_type == motif_category_type
  end
end
