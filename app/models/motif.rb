class Motif < ApplicationRecord
  SHARED_ATTRIBUTES_WITH_RDV_SOLIDARITES = [
    :name, :deleted_at, :location_type, :name, :reservable_online, :rdv_solidarites_service_id, :collectif,
    :follow_up
  ].freeze

  enum location_type: { public_office: 0, phone: 1, home: 2 }

  belongs_to :organisation
  belongs_to :motif_category, optional: true
  has_many :rdvs, dependent: :nullify

  validates :rdv_solidarites_motif_id, uniqueness: true, presence: true
  validates :name, :location_type, presence: true

  delegate :rdv_solidarites_organisation_id, to: :organisation

  scope :active, ->(active = true) { active ? where(deleted_at: nil) : where.not(deleted_at: nil) }
  scope :collectif, ->(collectif = true) { collectif ? where(collectif: true) : where(collectif: false) }

  def presential?
    location_type == "public_office"
  end

  def by_phone?
    location_type == "phone"
  end

  def convocation?
    name.downcase.include?("convocation")
  end
end
