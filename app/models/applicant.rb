class Applicant < ApplicationRecord
  SHARED_ATTRIBUTES_WITH_RDV_SOLIDARITES = [
    :first_name, :last_name, :birth_date, :email, :phone_number, :address, :affiliation_number
  ].freeze

  STATUSES_WITH_ACTION_REQUIRED = %w[
    not_invited rdv_needs_status_update rdv_noshow rdv_revoked rdv_excused
  ].freeze
  STATUSES_WITH_ATTENTION_NEEDED = %w[invitation_pending rdv_creation_pending].freeze

  include SearchableConcern
  include HasStatusConcern
  include NotificableConcern
  include HasPhoneNumberConcern

  has_and_belongs_to_many :organisations
  has_many :invitations, dependent: :nullify
  has_and_belongs_to_many :rdvs

  validates :uid, uniqueness: true, allow_nil: true
  validates :rdv_solidarites_user_id, uniqueness: true, allow_nil: true
  validates :last_name, :first_name, :title, presence: true
  validates :email, allow_blank: true, format: { with: /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]+\z/ }
  validate :birth_date_validity

  enum role: { demandeur: 0, conjoint: 1 }
  enum title: { monsieur: 0, madame: 1 }
  enum status: {
    not_invited: 0, invitation_pending: 1, rdv_creation_pending: 2, rdv_pending: 3,
    rdv_needs_status_update: 4, rdv_noshow: 5, rdv_revoked: 6, rdv_excused: 7,
    rdv_seen: 8, resolved: 9
  }

  scope :status, ->(status) { where(status: status) }
  scope :action_required, -> { status(STATUSES_WITH_ACTION_REQUIRED).or(attention_needed.invited_before_time_window) }
  scope :attention_needed, -> { status(STATUSES_WITH_ATTENTION_NEEDED) }
  scope :invited_before_time_window, lambda {
    where.not(id: Invitation.sent_in_time_window.pluck(:applicant_id).uniq)
  }
  scope :oriented, -> { where(status: %w[resolved rdv_seen]) }

  def birth_date_validity
    return unless birth_date.present? && (birth_date > Time.zone.today || birth_date < 130.years.ago)

    errors.add(:birth_date, "n'est pas valide")
  end

  def last_sent_invitation
    invitations.select(&:sent_at).max_by(&:sent_at)
  end

  def last_invitation_sent_at
    last_sent_invitation&.sent_at
  end

  def last_sent_sms_invitation
    invitations.select { |invitation| invitation.format == "sms" }.select(&:sent_at).max_by(&:sent_at)
  end

  def last_sms_invitation_sent_at
    last_sent_sms_invitation&.sent_at
  end

  def last_sent_email_invitation
    invitations.select { |invitation| invitation.format == "email" }.select(&:sent_at).max_by(&:sent_at)
  end

  def last_email_invitation_sent_at
    last_sent_email_invitation&.sent_at
  end

  def action_required?
    status.in?(STATUSES_WITH_ACTION_REQUIRED) || (attention_needed? && invited_before_time_window?)
  end

  def attention_needed?
    status.in?(STATUSES_WITH_ATTENTION_NEEDED)
  end

  def invited_before_time_window?
    last_invitation_sent_at && last_invitation_sent_at < Organisation::TIME_TO_ACCEPT_INVITATION.ago
  end

  def orientation_date
    if rdv_seen?
      rdvs.seen.first.starts_at
    elsif resolved? && oriented_at
      oriented_at
    elsif resolved?
      updated_at
    else
      DateTime.now
    end
  end

  def orientation_delay_in_days
    starting_date = created_at - 3.days
    orientation_date.to_datetime.mjd - starting_date.to_datetime.mjd
  end

  def full_name
    "#{title.capitalize} #{first_name.capitalize} #{last_name.upcase}"
  end

  def short_title
    title == "monsieur" ? "M" : "Mme"
  end

  def as_json(_opts = {})
    super.merge(
      created_at: created_at,
      invitations: invitations
    )
  end
end
