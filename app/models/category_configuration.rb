class CategoryConfiguration < ApplicationRecord
  include PhoneNumberValidation

  belongs_to :motif_category
  belongs_to :file_configuration
  belongs_to :organisation

  validates :organisation, uniqueness: { scope: :motif_category,
                                         message: "a déjà une category_configuration pour cette catégorie de motif" }
  validate :minimum_invitation_duration, :invitation_formats_validity, :periodic_invites_can_be_activated

  validates :email_to_notify_no_available_slots, :email_to_notify_rdv_changes,
            format: {
              with: /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9-]+(\.[A-Za-z0-9-]+)*\.[A-Za-z]{2,}\z/,
              allow_blank: true
            }
  validates :number_of_days_between_periodic_invites, numericality: { only_integer: true, greater_than: 13 },
                                                      allow_nil: true

  delegate :name, :short_name, to: :motif_category, prefix: true
  delegate :sheet_name, to: :file_configuration
  delegate :department, :rdv_solidarites_organisation_id, to: :organisation
  delegate :template, to: :motif_category

  def self.template_override_attributes
    attribute_names.select do |attribute_name|
      attribute_name.start_with?("template") && attribute_name.end_with?("override")
    end
  end

  def periodic_invites_activated?
    day_of_the_month_periodic_invites.present? || number_of_days_between_periodic_invites.present?
  end

  def phone_number
    attributes["phone_number"].presence || organisation.phone_number
  end

  def notify_no_available_slots? = email_to_notify_no_available_slots.present?
  def notify_rdv_changes? = email_to_notify_rdv_changes.present?

  def new_invitation_will_expire_at
    number_of_days_before_invitations_expire&.days&.from_now
  end

  private

  def periodic_invites_can_be_activated
    return unless periodic_invites_activated? && number_of_days_before_invitations_expire.present?

    errors.add(:base, "Les invitations périodiques ne peuvent pas être activées si " \
                      "les liens des invitations ont une durée de validitée définie. " \
                      "Veuillez retirer la limite de durée de validité des liens d'invitation, " \
                      "ou désactiver les invitations périodiques.")
  end

  def minimum_invitation_duration
    return if number_of_days_before_invitations_expire.nil? ||
              number_of_days_before_invitations_expire > Invitation::NUMBER_OF_DAYS_BEFORE_REMINDER

    errors.add(:base, "Le délai d'expiration de l'invitation doit être supérieur " \
                      "à #{Invitation::NUMBER_OF_DAYS_BEFORE_REMINDER} jours")
  end

  def invitation_formats_validity
    invitation_formats.each do |invitation_format|
      next if %w[sms email postal].include?(invitation_format)

      errors.add(:base, "Les formats d'invitation ne peuvent être que : sms, email, postal")
    end
  end
end
