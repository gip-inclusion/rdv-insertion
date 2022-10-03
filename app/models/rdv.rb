class Rdv < ApplicationRecord
  SHARED_ATTRIBUTES_WITH_RDV_SOLIDARITES = [
    :address, :cancelled_at, :context, :created_by, :duration_in_min, :starts_at, :status,
    :uuid, :rdv_solidarites_motif_id, :rdv_solidarites_lieu_id
  ].freeze
  PENDING_STATUSES = %w[unknown waiting].freeze
  CANCELLED_STATUSES = %w[excused revoked noshow].freeze
  CANCELLED_BY_USER_STATUSES = %w[excused noshow].freeze

  include NotificableConcern

  after_save :set_event_to_notify, if: :notify_applicants?
  after_commit :notify_applicants, if: :notify_applicants?, on: [:create, :update]
  after_commit :refresh_context_status, on: [:create, :update]

  belongs_to :organisation
  belongs_to :motif
  belongs_to :lieu, optional: true
  has_and_belongs_to_many :rdv_contexts
  has_and_belongs_to_many :applicants

  validates :applicants, :starts_at, :duration_in_min, presence: true
  validates :rdv_solidarites_rdv_id, uniqueness: true, presence: true

  validate :rdv_contexts_motif_categories_are_uniq

  enum created_by: { agent: 0, user: 1, file_attente: 2 }, _prefix: :created_by
  enum status: { unknown: 0, waiting: 1, seen: 2, excused: 3, revoked: 4, noshow: 5 }

  scope :cancelled_by_user, -> { where(status: CANCELLED_BY_USER_STATUSES) }
  scope :status, ->(status) { where(status: status) }
  scope :resolved, -> { where(status: %w[seen excused revoked noshow]) }

  def pending?
    in_the_future? && status.in?(PENDING_STATUSES)
  end

  def in_the_future?
    starts_at > Time.zone.now
  end

  def cancelled?
    status.in?(CANCELLED_STATUSES)
  end

  def resolved?
    status.in?(%w[seen excused revoked noshow])
  end

  def needs_status_update?
    !in_the_future? && status.in?(PENDING_STATUSES)
  end

  def delay_in_days
    starts_at.to_datetime.mjd - created_at.to_datetime.mjd
  end

  def rdv_solidarites_url
    "#{ENV['RDV_SOLIDARITES_URL']}/admin/organisations/" \
      "#{organisation.rdv_solidarites_organisation_id}/rdvs/#{rdv_solidarites_rdv_id}"
  end

  def notify_applicants?
    convocable?
  end

  def motif_category
    # we rely on the rdv contexts instead of the motif itself since the category on the motif
    # can be updated but not on the context
    rdv_contexts.first.motif_category
  end

  private

  def refresh_context_status
    RefreshRdvContextStatusesJob.perform_async(rdv_context_ids)
  end

  def notify_applicants
    return unless @event_to_notify

    NotifyRdvToApplicants.perform_async(id, @event_to_notify)
  end

  def set_event_to_notify
    @event_to_notify = \
      if new_record?
        :created
      elsif cancelled_at.present? && cancelled_at_changed?
        :cancelled
      elsif address_changed? || starts_at_changed?
        :updated
      end
  end

  def rdv_contexts_motif_categories_are_uniq
    return if rdv_contexts.pluck(:motif_category).uniq.length < 2

    errors.add(:base, "Un RDV ne peut pas être lié à deux catégories de motifs différents")
  end
end
