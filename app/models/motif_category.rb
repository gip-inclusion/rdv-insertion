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
  validates :rdv_solidarites_motif_category_id, uniqueness: true, allow_nil: true
  validate :selected_template_allows_mandatory_rdv_subscription

  delegate :model, to: :template, prefix: true
  delegate :atelier?, to: :template

  scope :optional_rdv_subscription, lambda { |optional_rdv_subscription = true|
    where(optional_rdv_subscription: optional_rdv_subscription)
  }

  def selected_template_allows_mandatory_rdv_subscription
    return unless template.model.include?("atelier") && !optional_rdv_subscription?

    errors.add(:base, "La participation doit être facultative pour un template de type atelier")
  end
end
