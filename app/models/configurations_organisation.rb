class ConfigurationsOrganisation < ApplicationRecord
  belongs_to :configuration
  belongs_to :organisation

  validate :organisation_not_already_attached_to_motif_category

  after_create :create_rdv_contexts_for_organisation_applicants

  private

  def organisation_not_already_attached_to_motif_category
    motif_categories = organisation.configurations.reject { |c| c.id == configuration.id }.map(&:motif_category)
    return unless motif_categories.include?(configuration.motif_category)

    errors.add(:base, "l'organisation est déjà rattachée à cette catégorie de motif")
  end

  # When we add motif category in an organisation, we want all the applicants to be linked
  # to this new category
  def create_rdv_contexts_for_organisation_applicants
    organisation.applicants.each do |applicant|
      RdvContext.find_or_create_by!(applicant: applicant, motif_category: configuration.motif_category)
    end
  end
end
