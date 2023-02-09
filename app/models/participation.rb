class Participation < ApplicationRecord
  include Notificable
  include RdvParticipationStatus

  belongs_to :rdv
  belongs_to :rdv_context
  belongs_to :applicant
  has_many :notifications, dependent: :nullify

  validates :status, presence: true
  validates :rdv_solidarites_participation_id, uniqueness: true, allow_nil: true

  after_commit :refresh_applicant_context_statuses
  after_commit :notify_applicant, if: :rdv_notify_applicants?, on: [:create, :update]

  delegate :starts_at, :convocable?, :motif_name, :rdv_solidarites_url, :rdv_solidarites_rdv_id, to: :rdv
  delegate :phone_number_is_mobile?, :email?, to: :applicant
  delegate :motif_category, to: :rdv_context
  delegate :notify_applicants?, to: :rdv, prefix: true

  private

  def refresh_applicant_context_statuses
    RefreshRdvContextStatusesJob.perform_async(rdv_context_id)
  end

  def status_reloaded_from_cancelled?
    status_previously_was.in?(CANCELLED_STATUSES) && status == "unknown"
  end

  def participation_cancelled?
    # Do not notify applicants for a cancelled event for a previously cancelled participation
    (status.in? CANCELLED_STATUSES) && !status_previously_was.in?(CANCELLED_STATUSES)
  end

  def notify_applicant
    return unless event_to_notify

    NotifyParticipationJob.perform_async(id, "sms", "participation_#{event_to_notify}") if phone_number_is_mobile?
    NotifyParticipationJob.perform_async(id, "email", "participation_#{event_to_notify}") if email?
  end

  def event_to_notify
    if id_previously_changed? || status_reloaded_from_cancelled?
      :created
    elsif participation_cancelled?
      :cancelled
    end
  end
end
