class Applicant < ApplicationRecord
  SHARED_ATTRIBUTES_WITH_RDV_SOLIDARITES = [
    :first_name, :last_name, :birth_date, :email, :phone_number, :address, :affiliation_number, :birth_name
  ].freeze
  RDV_SOLIDARITES_CLASS_NAME = "User".freeze
  REQUIRED_ATTRIBUTES_FOR_INVITATION_FORMATS = {
    "sms" => :phone_number,
    "email" => :email,
    "postal" => :address
  }.freeze
  SEARCH_ATTRIBUTES = [:first_name, :last_name, :affiliation_number, :email, :phone_number].freeze

  include Searchable
  include Notificable
  include PhoneNumberValidation
  include Invitable
  include HasParticipationsToRdvs
  include Applicant::TextHelper
  include Applicant::Nir
  include Applicant::Archivable

  before_validation :generate_uid
  before_save :format_phone_number

  has_and_belongs_to_many :organisations

  has_many :rdv_contexts, dependent: :destroy
  has_many :invitations, dependent: :destroy
  has_many :participations, dependent: :destroy
  has_many :archives, dependent: :destroy
  has_many :referent_assignations, dependent: :destroy

  has_many :rdvs, through: :participations
  has_many :notifications, through: :participations
  has_many :configurations, through: :organisations
  has_many :motif_categories, through: :rdv_contexts
  has_many :referents, through: :referent_assignations, source: :agent

  accepts_nested_attributes_for :rdv_contexts, reject_if: :rdv_context_category_handled_already?

  validates :last_name, :first_name, :title, presence: true
  validates :email, allow_blank: true, format: { with: /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]+\z/ }
  validate :birth_date_validity
  validates :rdv_solidarites_user_id, :nir, :pole_emploi_id,
            uniqueness: true, allow_nil: true, unless: :skip_uniqueness_validations
  attr_accessor :skip_uniqueness_validations

  delegate :name, :number, to: :department, prefix: true

  enum role: { demandeur: 0, conjoint: 1 }
  enum title: { monsieur: 0, madame: 1 }

  scope :active, -> { where(deleted_at: nil) }
  scope :without_rdv_contexts, lambda { |motif_categories|
    where.not(id: joins(:rdv_contexts).where(rdv_contexts: { motif_category: motif_categories }).ids)
  }
  scope :with_sent_invitations, -> { joins(:invitations).where.not(invitations: { sent_at: nil }).distinct }

  def rdv_seen_delay_in_days
    return if first_seen_rdv_starts_at.blank?

    first_seen_rdv_starts_at.to_datetime.mjd - created_at.to_datetime.mjd
  end

  def participation_for(rdv)
    participations.to_a.find { |participation| participation.rdv_id == rdv.id }
  end

  def street_address
    split_address.present? ? split_address[1].strip.gsub(/-$/, "").gsub(/,$/, "").gsub(/\.$/, "") : nil
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

  def rdv_context_for(motif_category)
    rdv_contexts.to_a.find { |rc| rc.motif_category_id == motif_category.id }
  end

  def deleted?
    deleted_at.present?
  end

  def can_be_invited_through?(invitation_format)
    send(REQUIRED_ATTRIBUTES_FOR_INVITATION_FORMATS[invitation_format]).present?
  end

  def soft_delete
    update_columns(
      deleted_at: Time.zone.now,
      affiliation_number: nil,
      role: nil,
      uid: nil,
      department_internal_id: nil,
      pole_emploi_id: nil,
      nir: nil,
      email: nil,
      phone_number: nil
    )
  end

  def as_json(_opts = {})
    super.merge(
      created_at: created_at,
      invitations: invitations,
      organisations: organisations,
      rdv_contexts: rdv_contexts,
      referents: referents,
      archives: archives
    )
  end

  private

  def rdv_context_category_handled_already?(rdv_context_attributes)
    rdv_context_attributes["motif_category_id"].in?(motif_categories.map(&:id))
  end

  def generate_uid
    # Base64 encoded "affiliation_number - role"
    return if deleted?
    return if affiliation_number.blank? || role.blank?

    self.uid = Base64.strict_encode64("#{affiliation_number} - #{role}")
  end

  def format_phone_number
    self.phone_number = PhoneNumberHelper.format_phone_number(phone_number)
  end

  def birth_date_validity
    return unless birth_date.present? && (birth_date > Time.zone.today || birth_date < 130.years.ago)

    errors.add(:birth_date, "n'est pas valide")
  end

  def split_address
    address&.match(/^(.+) (\d{5}.*)$/m)
  end
end
