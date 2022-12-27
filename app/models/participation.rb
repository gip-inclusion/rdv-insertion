class Participation < ApplicationRecord
  include Notificable
  include HasStatus

  delegate :starts_at, :notify_applicants?, to: :rdv

  validates :status, presence: true
  validates :rdv_solidarites_participation_id, uniqueness: true, allow_nil: true

  belongs_to :rdv
  belongs_to :applicant
  after_commit :refresh_applicant_context_statuses, on: [:destroy]
  after_commit :notify_applicant, if: :notify_applicants?, on: [:create, :update]

  private

  def refresh_applicant_context_statuses
    RefreshRdvContextStatusesJob.perform_async(applicant.rdv_context_ids)
  end

  def status_reloaded_from_cancelled?
    status_previously_was.in?(CANCELLED_STATUSES) && status == "unknown"
  end

  def notify_applicant
    return unless event_to_notify

    notification_event = "rdv_#{event_to_notify}"
    if applicant.phone_number_is_mobile?
      NotifyRdvToApplicantJob.perform_async(rdv_id, applicant_id, "sms", notification_event)
    end
    NotifyRdvToApplicantJob.perform_async(rdv_id, applicant_id, "email", notification_event) if applicant.email?
  end

  def event_to_notify
    if id_previously_changed? || status_reloaded_from_cancelled?
      :created
    elsif cancelled_at.present? && cancelled_at_previously_changed?
      :cancelled
    end
  end

  def notifications
    applicant.notifications.where(rdv: rdv)
  end
end
