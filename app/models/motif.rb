class Motif < ApplicationRecord
  SHARED_ATTRIBUTES_WITH_RDV_SOLIDARITES = [
    :deleted_at, :location_type, :name, :bookable_by, :rdv_solidarites_service_id, :collectif,
    :follow_up, :instruction_for_rdv, :default_duration_in_min
  ].freeze

  enum :location_type, { public_office: "public_office", phone: "phone", home: "home" }

  belongs_to :organisation
  belongs_to :motif_category, optional: true
  has_many :rdvs, dependent: :nullify

  validates :rdv_solidarites_motif_id, uniqueness: true, presence: true
  validates :name, :location_type, :default_duration_in_min, presence: true
  validates :collectif, inclusion: { in: [true, false] }

  delegate :rdv_solidarites_organisation_id, to: :organisation

  scope :active, ->(active = true) { active ? where(deleted_at: nil) : where.not(deleted_at: nil) }
  scope :collectif, -> { where(collectif: true) }
  scope :individuel, -> { where(collectif: false) }

  after_commit :alert_motif_category_has_changed, on: %i[update]

  def presential?
    location_type == "public_office"
  end

  def by_phone?
    location_type == "phone"
  end

  def convocation?
    name.downcase.include?("convocation")
  end

  def bookable_by_invited_users?
    bookable_by.in?(%w[agents_and_prescripteurs_and_invited_users])
  end

  def link_to_take_rdv_for(rdv_solidarites_user_id)
    params = {
      user_ids: [rdv_solidarites_user_id],
      motif_id: rdv_solidarites_motif_id,
      service_id: rdv_solidarites_service_id,
      commit: "Afficher les créneaux"
    }
    "#{ENV['RDV_SOLIDARITES_URL']}/admin/organisations/#{rdv_solidarites_organisation_id}/" \
      "agent_searches?#{params.to_query}"
  end

  def alert_motif_category_has_changed
    return unless motif_category_id_previously_changed? && motif_category_id_previously_was.present? && rdvs.any?

    AlertMotifCategoryHasChangedJob.perform_later(id)
  end
end
