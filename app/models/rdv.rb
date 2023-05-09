class Rdv < ApplicationRecord
  SHARED_ATTRIBUTES_WITH_RDV_SOLIDARITES = [
    :address, :cancelled_at, :context, :created_by, :duration_in_min, :starts_at, :status, :uuid
  ].freeze

  include Notificable
  include RdvParticipationStatus

  after_commit :notify_applicants, if: :notify_applicants?, on: [:create, :update]
  after_commit :refresh_context_status, on: [:create, :update]

  belongs_to :organisation
  belongs_to :motif
  belongs_to :lieu, optional: true
  has_many :participations, dependent: :destroy
  has_many :notifications, through: :participations
  has_many :rdv_contexts, through: :participations
  has_many :applicants, through: :participations

  # Needed to build participations in process_rdv_job
  accepts_nested_attributes_for :participations, allow_destroy: true

  validates :participations, :starts_at, :duration_in_min, presence: true
  validates :rdv_solidarites_rdv_id, uniqueness: true, presence: true

  validate :rdv_contexts_motif_categories_are_uniq

  enum created_by: { agent: 0, user: 1, file_attente: 2, prescripteur: 3 }, _prefix: :created_by

  delegate :presential?, :by_phone?, to: :motif
  delegate :department, to: :organisation
  delegate :name, to: :motif, prefix: true

  scope :with_lieu, -> { where.not(lieu_id: nil) }

  def rdv_solidarites_url
    "#{ENV['RDV_SOLIDARITES_URL']}/admin/organisations/" \
      "#{organisation.rdv_solidarites_organisation_id}/rdvs/#{rdv_solidarites_rdv_id}"
  end

  def notify_applicants?
    convocable?
  end

  def formatted_start_date
    starts_at.to_datetime.strftime("%d/%m/%Y")
  end

  def formatted_start_time
    starts_at.to_datetime.strftime("%H:%M")
  end

  def phone_number
    return lieu.phone_number if lieu&.phone_number.present?

    organisation.phone_number
  end

  private

  def refresh_context_status
    RefreshRdvContextStatusesJob.perform_async(rdv_context_ids)
  end

  def notify_applicants
    return unless event_to_notify

    NotifyParticipationsJob.perform_async(participation_ids, event_to_notify)
  end

  # event to notify in an after_commit context
  def event_to_notify
    # the :created notifications are handled by participations
    return if id_previously_changed?

    return :updated if address_previously_changed? || starts_at_previously_changed?
  end

  def rdv_contexts_motif_categories_are_uniq
    return if rdv_contexts.map(&:motif_category).uniq.length < 2

    errors.add(:base, "Un RDV ne peut pas être lié à deux catégories de motifs différents")
  end
end
