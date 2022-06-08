class RdvContext < ApplicationRecord
  include HasMotifCategoryConcern
  include HasStatusConcern
  include InvitableConcern

  has_many :invitations, dependent: :destroy
  has_and_belongs_to_many :rdvs
  belongs_to :applicant

  validates :motif_category, presence: true, uniqueness: { scope: :applicant_id }

  STATUSES_WITH_ACTION_REQUIRED = %w[
    not_invited rdv_needs_status_update rdv_noshow rdv_revoked rdv_excused multiple_rdvs_cancelled
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

  def first_rdv_creation_date
    rdvs.select(&:created_at).min_by(&:created_at).created_at
  end

  def last_seen_rdv
    rdvs.select(&:seen?).max_by(&:starts_at)
  end

  def last_seen_rdv_starts_at
    last_seen_rdv&.starts_at
  end

  def time_between_invitation_and_rdv_in_days
    first_rdv_creation_date.to_datetime.mjd - first_invitation_sent_at.to_datetime.mjd
  end
end
