class RdvContext < ApplicationRecord
  include HasContextConcern
  include HasContextStatusConcern
  include InvitableConcern

  has_many :invitations, dependent: :destroy
  has_and_belongs_to_many :rdvs
  belongs_to :applicant

  validates :context, uniqueness: { scope: :applicant_id }

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
    where.not(id: Invitation.sent_in_time_window(number_of_days_before_action_required).pluck(:rdv_context_id).uniq)
  }

  def action_required?(number_of_days_before_action_required)
    status.in?(STATUSES_WITH_ACTION_REQUIRED) ||
      (attention_needed? && invited_before_time_window?(number_of_days_before_action_required))
  end

  def attention_needed?
    status.in?(STATUSES_WITH_ATTENTION_NEEDED)
  end

  def invitation_delay_in_days
    first_rdv_creation_date = rdvs.select(&:created_at).min_by(&:created_at).created_at
    first_rdv_creation_date.to_datetime.mjd - first_invitation_sent_at.to_datetime.mjd
  end
end
