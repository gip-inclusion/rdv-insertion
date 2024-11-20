class FollowUp < ApplicationRecord
  include FollowUpStatus
  include Invitable
  include Notificable
  include HasParticipationsToRdvs

  belongs_to :user
  belongs_to :motif_category
  has_many :invitations, dependent: :destroy
  has_many :participations, dependent: :nullify

  has_many :rdvs, through: :participations
  has_many :notifications, through: :participations

  broadcasts_refreshes

  validates :user, uniqueness: { scope: :motif_category,
                                 message: "est déjà suivi pour cette catégorie de motif" }

  delegate :name, :short_name, to: :motif_category, prefix: true

  STATUSES_WITH_ACTION_REQUIRED = %w[
    rdv_needs_status_update rdv_noshow rdv_revoked rdv_excused
  ].freeze
  CONVOCABLE_STATUSES = %w[
    rdv_noshow rdv_excused
  ].freeze

  scope :status, ->(status) { where(status: status) }
  scope :action_required, lambda {
                            status(STATUSES_WITH_ACTION_REQUIRED).or(
                              status("invitation_pending").where(id: with_all_invitations_expired)
                            )
                          }
  scope :with_all_invitations_expired, -> { joins(:invitations).where.not(invitations: Invitation.valid) }
  scope :with_sent_invitations, -> { where.associated(:invitations) }
  scope :orientation, -> { joins(:motif_category).where(motif_category: { motif_category_type: "rsa_orientation" }) }
  scope :accompaniment, lambda {
                          joins(:motif_category).where(motif_category: { motif_category_type: "rsa_accompagnement" })
                        }

  def action_required_status?
    status.in?(STATUSES_WITH_ACTION_REQUIRED)
  end

  def convocable_status?
    status.in?(CONVOCABLE_STATUSES)
  end

  def no_upcoming_rdv_and_all_invitations_expired?
    status == "invitation_pending" && all_invitations_expired?
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

  def current_pending_rdv
    # if rdv is the same day, it is not in the future therefore not considered "pending", but the follow-up is still
    participations.select(&:pending?).min_by(&:starts_at) || participations.select(&:unknown?).max_by(&:starts_at)
  end
end
