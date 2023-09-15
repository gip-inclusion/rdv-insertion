class Configuration < ApplicationRecord
  belongs_to :motif_category
  belongs_to :file_configuration
  belongs_to :organisation

  validates :organisation, uniqueness: { scope: :motif_category,
                                         message: "a déjà une configuration pour cette catégorie de motif" }
  validate :delays_validity, :invitation_formats_validity

  delegate :position, :name, to: :motif_category, prefix: true
  delegate :sheet_name, to: :file_configuration
  delegate :department, to: :organisation
  delegate :template, to: :motif_category

  def self.template_override_attributes
    attribute_names.select do |attribute_name|
      attribute_name.start_with?("template") && attribute_name.end_with?("override")
    end
  end

  def periodic_invites_activated?
    periodic_invites_enabled &&
      (day_of_the_month_periodic_invites.present? || number_of_days_between_periodic_invites.present?)
  end

  private

  def delays_validity
    return if number_of_days_before_action_required > Invitation::NUMBER_OF_DAYS_BEFORE_REMINDER

    errors.add(:base, "Le délai d'expiration de l'invtation doit être supérieur " \
                      "à #{Invitation::NUMBER_OF_DAYS_BEFORE_REMINDER} jours")
  end

  def invitation_formats_validity
    invitation_formats.each do |invitation_format|
      next if %w[sms email postal].include?(invitation_format)

      errors.add(:base, "Les formats d'invitation ne peuvent être que : sms, email, postal")
    end
  end
end
