module Invitations
  class Validate < BaseService
    attr_reader :invitation

    delegate :user,
             :organisations,
             :motif_category,
             :valid_until,
             :motif_category_name,
             :department_id,
             :link_params, to: :invitation

    def initialize(invitation:, rdv_solidarites_session: nil)
      @invitation = invitation
      @rdv_solidarites_session = rdv_solidarites_session
    end

    def call
      validate_user_title_presence
      validate_organisations_are_not_from_different_departments
      validate_it_expires_in_more_than_5_days if @invitation.format_postal?
      validate_user_belongs_to_an_org_linked_to_motif_category
      validate_motif_of_this_category_is_defined_in_organisations
      validate_referents_are_assigned if @invitation.rdv_with_referents?
      validate_follow_up_motifs_are_defined if @invitation.rdv_with_referents?
      # we return here because we do not want to make a call to rdv_solidarites_api if invitation is already invalid
      return if result.errors.any?

      # rdv_solidarites_session is nil in CronJob. We do not want to validate creneau availability in this case
      # because it would prevent the cron job from sending specific invitations and agents will not be informed
      validate_existing_creneau_in_rdv_solidarites unless @rdv_solidarites_session.nil?
    end

    private

    def validate_user_title_presence
      return if user.title?

      result.errors << "La civilité de la personne doit être précisée pour pouvoir envoyer une invitation"
    end

    def validate_organisations_are_not_from_different_departments
      return if organisations.map(&:department_id).uniq == [department_id]

      result.errors << "Les organisations ne peuvent pas être liés à des départements différents de l'invitation"
    end

    def validate_it_expires_in_more_than_5_days
      return if valid_until > 5.days.from_now

      result.errors << "La durée de validité de l'invitation pour un courrier doit être supérieure à 5 jours"
    end

    def validate_user_belongs_to_an_org_linked_to_motif_category
      return if user.organisations.flat_map(&:motif_categories).include?(motif_category)

      result.errors << "L'usager n'appartient pas à une organisation qui gère la catégorie #{motif_category_name}"
    end

    def validate_motif_of_this_category_is_defined_in_organisations
      return if organisations_motifs.map(&:motif_category).include?(motif_category)

      result.errors << "Aucun motif de la catégorie #{motif_category_name} n'est défini sur RDV-Solidarités"
    end

    def validate_referents_are_assigned
      return if user.referent_ids.any?

      result.errors << "Un référent doit être assigné au bénéficiaire pour les rdvs avec référents"
    end

    def validate_follow_up_motifs_are_defined
      return if organisations_motifs.any? do |motif|
        motif.follow_up? && motif.motif_category == motif_category
      end

      result.errors << "Aucun motif de suivi n'a été défini pour la catégorie #{motif_category_name}"
    end

    def validate_existing_creneau_in_rdv_solidarites
      return if retrieve_creneau_availability.creneau_availability

      result.errors << "L'envoi d'une invitation est impossible car il n'y a plus de créneaux disponibles. " \
                       "Nous invitons donc à créer de nouvelles plages d'ouverture depuis l'interface " \
                       "RDV-Solidarités pour pouvoir à nouveau envoyer des invitations"
    end

    def organisations_motifs
      @organisations_motifs ||= Motif.includes(:motif_category).where(organisation_id: organisations.map(&:id))
    end

    def retrieve_creneau_availability
      @retrieve_creneau_availability ||= call_service!(
        RdvSolidaritesApi::RetrieveCreneauAvailability,
        rdv_solidarites_session: @rdv_solidarites_session,
        link_params: link_params
      )
    end
  end
end
