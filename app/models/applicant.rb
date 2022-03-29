class Applicant < ApplicationRecord
  SHARED_ATTRIBUTES_WITH_RDV_SOLIDARITES = [
    :first_name, :last_name, :birth_date, :email, :phone_number, :address, :affiliation_number, :birth_name,
    :invitation_accepted_at
  ].freeze

  STATUSES_WITH_ACTION_REQUIRED = %w[
    not_invited rdv_needs_status_update rdv_noshow rdv_revoked rdv_excused multiple_rdvs_cancelled
  ].freeze
  STATUSES_WITH_ATTENTION_NEEDED = %w[invitation_pending rdv_creation_pending].freeze
  RDV_SOLIDARITES_CLASS_NAME = "User".freeze

  include SearchableConcern
  include HasStatusConcern
  include NotificableConcern
  include HasPhoneNumberConcern
  include InvitableConcern

  before_validation :generate_uid

  has_and_belongs_to_many :organisations
  has_many :invitations, dependent: :destroy
  has_and_belongs_to_many :rdvs
  belongs_to :department

  validates :uid, uniqueness: true, allow_nil: true
  validates :rdv_solidarites_user_id, uniqueness: true, allow_nil: true
  validates :department_internal_id, uniqueness: { scope: :department_id }, allow_nil: true
  validates :last_name, :first_name, :title, presence: true
  validates :affiliation_number, presence: true, allow_nil: true
  validates :email, allow_blank: true, format: { with: /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]+\z/ }
  validate :birth_date_validity
  validate :uid_or_department_internal_id_presence

  enum role: { demandeur: 0, conjoint: 1 }
  enum title: { monsieur: 0, madame: 1 }
  enum status: {
    not_invited: 0, invitation_pending: 1, rdv_creation_pending: 2, rdv_pending: 3,
    rdv_needs_status_update: 4, rdv_noshow: 5, rdv_revoked: 6, rdv_excused: 7,
    rdv_seen: 8, archived: 9, deleted: 10, multiple_rdvs_cancelled: 11
  }

  scope :status, ->(status) { where(status: status) }
  scope :action_required, -> { status(STATUSES_WITH_ACTION_REQUIRED).or(attention_needed.invited_before_time_window) }
  scope :attention_needed, -> { status(STATUSES_WITH_ATTENTION_NEEDED) }
  scope :invited_before_time_window, lambda {
    where.not(id: Invitation.sent_in_time_window.pluck(:applicant_id).uniq)
  }

  def action_required?
    status.in?(STATUSES_WITH_ACTION_REQUIRED) ||
      (attention_needed? && invited_before_time_window?)
  end

  def attention_needed?
    status.in?(STATUSES_WITH_ATTENTION_NEEDED)
  end

  def invited_before_time_window?
    last_invitation_sent_at && last_invitation_sent_at < Organisation::TIME_TO_ACCEPT_INVITATION.ago
  end

  def orientation_date
    rdvs.find(&:seen?)&.starts_at
  end

  def oriented?
    orientation_date.present?
  end

  def orientation_delay_in_days
    return unless oriented?

    starting_date = rights_opening_date || (created_at - 3.days)
    orientation_date.to_datetime.mjd - starting_date.to_datetime.mjd
  end

  def full_name
    "#{title.capitalize} #{first_name.capitalize} #{last_name.upcase}"
  end

  def short_title
    title == "monsieur" ? "M" : "Mme"
  end

  def street_address
    split_address.present? ? split_address[1].strip.gsub(/-$/, '').gsub(/,$/, '').gsub(/\.$/, '') : nil
  end

  def zipcode_and_city
    split_address.present? ? split_address[2].strip : nil
  end

  def organisations_with_rdvs
    organisations.where(id: rdvs.pluck(:organisation_id))
  end

  def delete_organisation(organisation)
    organisations.delete(organisation)
    save!
  end

  def as_json(_opts = {})
    super.merge(
      created_at: created_at,
      invitations: invitations,
      organisations: organisations
    )
  end

  private

  def generate_uid
    # Base64 encoded "department_number - affiliation_number - role"
    return if deleted?
    return if department_id.blank? || affiliation_number.blank? || role.blank?

    self.uid = Base64.strict_encode64("#{department.number} - #{affiliation_number} - #{role}")
  end

  def birth_date_validity
    return unless birth_date.present? && (birth_date > Time.zone.today || birth_date < 130.years.ago)

    errors.add(:birth_date, "n'est pas valide")
  end

  def uid_or_department_internal_id_presence
    return if department_internal_id.present? || (affiliation_number.present? && role.present?)

    errors.add(:base, "le couple numéro d'allocataire + rôle ou l'ID interne au département doivent être présents.")
  end

  def split_address
    address&.match(/^(.+) (\d{5}.*)$/m)
  end
end
