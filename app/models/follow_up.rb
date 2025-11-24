class FollowUp < ApplicationRecord
  include FollowUpStatus
  include Invitable
  include Notificable
  include HasParticipationsToRdvs

  belongs_to :user
  belongs_to :motif_category
  has_many :invitations, dependent: :destroy
  has_many :participations, dependent: :destroy

  has_many :rdvs, through: :participations
  has_many :notifications, through: :participations

  broadcasts_refreshes

  validates :user, uniqueness: { scope: :motif_category,
                                 message: "est déjà suivi pour cette catégorie de motif" }

  delegate :name, :short_name, to: :motif_category, prefix: true

  STATUSES_WITH_ACTION_REQUIRED = %w[
    invitation_expired rdv_needs_status_update rdv_noshow rdv_revoked rdv_excused
  ].freeze
  CONVOCABLE_STATUSES = %w[
    invitation_expired rdv_noshow rdv_excused
  ].freeze

  scope :status, ->(status) { where(status: status) }
  scope :action_required, -> { status(STATUSES_WITH_ACTION_REQUIRED) }
  scope :with_sent_invitations, -> { where.associated(:invitations) }
  scope :orientation, -> { joins(:motif_category).where(motif_category: { motif_category_type: "rsa_orientation" }) }
  scope :accompagnement, lambda {
                           joins(:motif_category).where(motif_category: { motif_category_type: "rsa_accompagnement" })
                         }

  def convocable_status?
    status.in?(CONVOCABLE_STATUSES)
  end

  def time_between_invitation_and_rdv_in_days
    first_participation_creation_date.to_datetime.mjd - first_invitation_created_at.to_datetime.mjd
  end

  def closed?
    closed_at.present?
  end

  def orientation?
    motif_category.rsa_orientation?
  end

  def human_status
    I18n.t("activerecord.attributes.follow_up.statuses.#{status}")
  end

  def pending_rdv
    return unless rdv_pending?

    # normally there should always be pending participations for this follow_up status,
    # but if a participation happened today and its status has not been filled by the agent,
    # the participation would not be considered as pending anymore.
    # Also in that case the follow_up does not transition to rdv_needs_status_update until the CRON job
    # RefreshOutdatedFollowUpsStatusesJob runs.
    # So for this edge case we select the latest participation with an unknown status.
    participations.select(&:pending?).min_by(&:starts_at) || participations.select(&:unknown?).max_by(&:starts_at)
  end

  def days_between_follow_up_creation_and_first_seen_rdv
    return unless seen_rdvs?

    first_seen_rdv_starts_at.to_datetime.mjd - created_at.to_datetime.mjd
  end

  def days_between_first_orientation_seen_rdv_and_first_seen_rdv
    return unless seen_rdvs?
    return unless first_orientation_seen_rdv_date

    (first_seen_rdv_starts_at.to_datetime.mjd - first_orientation_seen_rdv_date.to_datetime.mjd)
  end

  def refresh_status_at
    start_from = [last_invitation_expires_at, last_rdv_starts_at].compact.max
    start_from + 1.second if start_from
  end

  private

  def first_orientation_seen_rdv_date
    @first_orientation_seen_rdv_date ||= user
                                         .follow_ups
                                         .orientation
                                         .min_by(&:created_at)
                                         &.first_seen_rdv_starts_at
  end
end
