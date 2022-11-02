module Invitations
  class Validate < BaseService
    attr_reader :invitation

    delegate :applicant, :organisations, :motif_category, :valid_until, :motif_category_human, :department_id,
             to: :invitation

    def initialize(invitation:)
      @invitation = invitation
    end

    def call
      validate_organisations_are_not_from_different_departments
      validate_it_expires_in_more_than_5_days if @invitation.format_postal?
      validate_applicant_belongs_to_an_org_linked_to_motif_category
      validate_motif_of_this_category_is_defined_in_organisations
    end

    private

    def validate_organisations_are_not_from_different_departments
      return if organisations.map(&:department_id).uniq == [department_id]

      result.errors << "Les organisations ne peuvent pas être liés à des départements différents de l'invitation"
    end

    def validate_it_expires_in_more_than_5_days
      return if valid_until > 5.days.from_now

      result.errors << "La durée de validité de l'invitation pour un courrier doit être supérieure à 5 jours"
    end

    def validate_applicant_belongs_to_an_org_linked_to_motif_category
      return if applicant.configurations_motif_categories.include?(motif_category)

      result.errors << "L'allocataire n'appartient pas à une organisation qui gère la catégorie #{motif_category_human}"
    end

    def validate_motif_of_this_category_is_defined_in_organisations
      return if organisations.flat_map(&:motifs).map(&:category).include?(motif_category)

      result.errors << "Aucun motif de la catégorie #{motif_category_human} n'est défini sur RDV-Solidarités"
    end
  end
end
