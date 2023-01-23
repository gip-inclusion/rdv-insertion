class RdvContext < ApplicationRecord
  include HasMotifCategory
  include RdvContextStatus
  include Invitable
  include Notificable
  include HasRdvs
  include HasParticipations

  belongs_to :applicant
  has_many :invitations, dependent: :nullify
  has_many :participations, dependent: :nullify
  has_many :rdvs, through: :participations
  has_many :notifications, through: :participations

  validates :motif_category, presence: true, uniqueness: { scope: :applicant_id }

  STATUSES_WITH_ACTION_REQUIRED = %w[
    rdv_needs_status_update rdv_noshow rdv_revoked rdv_excused multiple_rdvs_cancelled
  ].freeze
  STATUSES_WITH_ATTENTION_NEEDED = %w[invitation_pending].freeze

  scope :status, ->(status) { where(status: status) }
  scope :action_required, lambda { |number_of_days_before_action_required|
    status(STATUSES_WITH_ACTION_REQUIRED)
      .or(attention_needed.invited_before_time_window(number_of_days_before_action_required))
  }
  scope :attention_needed, -> { status(STATUSES_WITH_ATTENTION_NEEDED) }
  scope :invited_before_time_window, lambda { |number_of_days_before_action_required|
    where(id: joins(:invitations).where("invitations.sent_at < ?", number_of_days_before_action_required.days.ago))
  }
  scope :with_sent_invitations, -> { joins(:invitations).where.not(invitations: { sent_at: nil }) }

  def action_required?(number_of_days_before_action_required)
    status.in?(STATUSES_WITH_ACTION_REQUIRED) ||
      (attention_needed? && invited_before_time_window?(number_of_days_before_action_required))
  end

  def attention_needed?
    status.in?(STATUSES_WITH_ATTENTION_NEEDED)
  end

  def motif_orientation?
    motif_category.in?(%w[rsa_orientation rsa_orientation_on_phone_platform])
  end

  def time_between_invitation_and_rdv_in_days
    first_rdv_creation_date.to_datetime.mjd - first_invitation_sent_at.to_datetime.mjd
  end

  def as_json(_opts = {})
    super.merge(
      human_status: I18n.t("activerecord.attributes.rdv_context.statuses.#{status}"),
      participations: participations
    )
  end
end
