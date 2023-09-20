class Participation < ApplicationRecord
  include Notificable
  include RdvParticipationStatus

  belongs_to :rdv
  belongs_to :rdv_context
  belongs_to :user
  has_many :notifications, dependent: :nullify

  validates :status, presence: true
  validates :rdv_solidarites_participation_id, uniqueness: true, allow_nil: true

  after_commit :refresh_user_context_statuses
  after_commit :notify_user, if: :convocable?, on: [:create, :update]

  enum created_by: { agent: "agent", user: "user", prescripteur: "prescripteur" }, _prefix: :created_by

  delegate :organisation, :department, :starts_at, :motif_name,
           :rdv_solidarites_url, :rdv_solidarites_rdv_id, :instruction_for_rdv,
           to: :rdv
  delegate :phone_number_is_mobile?, :email?, to: :user
  delegate :motif_category, to: :rdv_context

  private

  def refresh_user_context_statuses
    RefreshRdvContextStatusesJob.perform_async(rdv_context_id)
  end

  def status_reloaded_from_cancelled?
    status_previously_was.in?(CANCELLED_STATUSES) && status == "unknown"
  end

  def participation_cancelled?
    # Do not notify users for a cancelled event for a previously cancelled participation
    (status.in? CANCELLED_STATUSES) && !status_previously_was.in?(CANCELLED_STATUSES)
  end

  def notify_user
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
