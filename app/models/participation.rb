class Participation < ApplicationRecord
  include Notificable
  include HasCurrentCategoryConfiguration
  include RdvParticipationStatus
  include Participation::FranceTravailWebhooks
  include Participation::FranceTravailPayload

  belongs_to :rdv
  belongs_to :follow_up
  belongs_to :user

  has_many :notifications, dependent: :destroy
  has_many :follow_up_invitations, through: :follow_up, source: :invitations
  has_many :agents, through: :rdv

  has_one :organisation, through: :rdv

  has_many :category_configurations, through: :organisation

  validates :status, presence: true
  validates :rdv_solidarites_participation_id, uniqueness: true, allow_nil: true

  after_commit :refresh_follow_up_status
  after_commit :notify_user, if: :should_notify_user?, on: [:create, :update]
  after_commit :notify_external, if: :should_notify_external?, on: [:create, :update]

  enum :created_by_type, { agent: "Agent", user: "User", prescripteur: "Prescripteur" }, prefix: true

  delegate :starts_at, :motif, :lieu, :collectif?, :by_phone?, :duration_in_min,
           :rdv_solidarites_url, :rdv_solidarites_rdv_id, :instruction_for_rdv, :address,
           to: :rdv
  delegate :department, :department_id, to: :organisation
  delegate :phone_number_is_mobile?, :email?, to: :user
  delegate :motif_category, :orientation?, to: :follow_up

  alias_method :created_by_agent?, :created_by_type_agent?
  alias_method :created_by_prescripteur?, :created_by_type_prescripteur?
  alias_method :created_by_user?, :created_by_type_user?

  def created_by
    if created_by_agent?
      Agent.find_by(rdv_solidarites_agent_id: rdv_solidarites_created_by_id)
    elsif created_by_user?
      User.find_by(rdv_solidarites_user_id: rdv_solidarites_created_by_id)
    end
  end

  def agent_prescripteur
    created_by if created_by_agent_prescripteur?
  end

  def notifiable?
    convocable? && in_the_future? && status.in?(%w[unknown revoked])
  end

  private

  def refresh_follow_up_status
    RefreshFollowUpStatusesJob.perform_later(follow_up_id)
  end

  def status_reloaded_from_cancelled?
    status_previously_was.in?(CANCELLED_STATUSES) && status.in?(%w[unknown])
  end

  def participation_just_cancelled?
    # Do not notify users for a cancelled event for a previously cancelled participation
    status.in?(CANCELLED_STATUSES) && !status_previously_was.in?(CANCELLED_STATUSES)
  end

  def should_notify_user?
    notifiable? && event_to_notify
  end

  def should_notify_external?
    current_category_configuration&.notify_rdv_changes? && rdv.in_the_future?
  end

  def notify_user
    if phone_number_is_mobile?
      NotifyParticipationToUserJob.perform_later(id, "sms",
                                                 "participation_#{event_to_notify}")
    end
    NotifyParticipationToUserJob.perform_later(id, "email", "participation_#{event_to_notify}") if email?
  end

  def notify_external
    NotifyRdvChangesToExternalOrganisationEmailJob.perform_later(
      [id],
      rdv_id,
      event_to_notify || :updated
    )
  end

  def event_to_notify
    if id_previously_changed? || status_reloaded_from_cancelled?
      :created
    elsif participation_just_cancelled?
      :cancelled
    end
  end
end
