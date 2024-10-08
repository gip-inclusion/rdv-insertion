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
  validate :selected_template_allows_mandatory_rdv_subscription

  delegate :model, to: :template, prefix: true
  delegate :atelier?, to: :template

  enum motif_category_type: { autre: "autre", siae: "siae", rsa_orientation: "rsa_orientation",
                              rsa_accompagnement: "rsa_accompagnement" }

  scope :optional_rdv_subscription, lambda { |optional_rdv_subscription = true|
    where(optional_rdv_subscription: optional_rdv_subscription)
  }

  def selected_template_allows_mandatory_rdv_subscription
    return if
      optional_rdv_subscription? ||
      Rails
      .root
      .join("app", "views", "mailers", "invitation_mailer", "#{template&.model}_invitation_reminder.html.erb")
      .exist?

    errors.add(:base, "Ce modèle de RDV n'est pas compatible avec un suivi obligatoire (email de rappel non configuré)")
  end
end
