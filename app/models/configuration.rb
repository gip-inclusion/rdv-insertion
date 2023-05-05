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

  after_create :create_rdv_contexts_for_organisation_applicants

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

  # When we add motif category in an organisation, we want all the applicants to be linked
  # to this new category
  def create_rdv_contexts_for_organisation_applicants
    organisation.applicants.each do |applicant|
      RdvContext.find_or_create_by!(applicant: applicant, motif_category: motif_category)
    end
  end
end
