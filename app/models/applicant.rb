# rubocop:disable Metrics/ClassLength

class Applicant < ApplicationRecord
  SHARED_ATTRIBUTES_WITH_RDV_SOLIDARITES = [
    :first_name, :last_name, :birth_date, :email, :phone_number, :address, :affiliation_number, :birth_name
  ].freeze
  RDV_SOLIDARITES_CLASS_NAME = "User".freeze

  include SearchableConcern
  include NotificableConcern
  include HasPhoneNumberConcern
  include InvitableConcern

  before_validation :generate_uid

  has_and_belongs_to_many :organisations
  has_many :invitations, dependent: :destroy
  has_many :rdv_contexts, dependent: :destroy
  has_and_belongs_to_many :rdvs
  belongs_to :department

  validates :uid, uniqueness: true, allow_nil: true
  validates :rdv_solidarites_user_id, uniqueness: true, allow_nil: true
  validates :department_internal_id, uniqueness: { scope: :department_id }, allow_nil: true
  validates :last_name, :first_name, :title, presence: true
  validates :affiliation_number, presence: true, allow_nil: true
  validates :email, allow_blank: true, format: { with: /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]+\z/ }
  validate :birth_date_validity, :uid_or_department_internal_id_presence

  enum role: { demandeur: 0, conjoint: 1 }
  enum title: { monsieur: 0, madame: 1 }

  scope :active, -> { where(deleted_at: nil) }
  scope :archived, ->(archived = true) { where(is_archived: archived) }
  scope :without_rdv_contexts, lambda { |contexts|
    where.not(id: joins(:rdv_contexts).where(rdv_contexts: { context: contexts }).ids)
  }

  def orientation_path_starting_date
    rights_opening_date || (created_at - 3.days)
  end

  def orientations_rdvs
    rdv_contexts.select(&:context_orientation?).flat_map(&:rdvs)
  end

  def orientation_date
    @orientation_date ||= orientations_rdvs.to_a.select(&:seen?).min_by(&:starts_at)&.starts_at
  end

  def oriented?
    orientation_date.present?
  end

  def orientation_delay_in_days
    return unless oriented?

    orientation_date.to_datetime.mjd - orientation_path_starting_date.to_datetime.mjd
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

  def rdv_context_for(context)
    rdv_contexts.find { |rc| rc.context == context }
  end

  def deleted?
    deleted_at.present?
  end

  def contexts
    rdv_contexts.map(&:context)
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

# rubocop: enable Metrics/ClassLength
