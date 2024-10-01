module Invitations
  class Validate < BaseService
    attr_reader :invitation

    delegate :user,
             :organisations,
             :motif_category,
             :follow_up,
             :expires_at,
             :motif_category_name,
             :department_id,
             :help_phone_number,
             to: :invitation

    def initialize(invitation:)
      @invitation = invitation
    end

    def call
      validate_invitation_not_already_sent_today
      validate_user_title_presence
      validate_help_phone_number_presence
      validate_user_belongs_to_an_org_linked_to_motif_category
      validate_organisations_are_not_from_different_departments
      validate_no_rdv_pending_taken_today
      validate_it_expires_in_more_than_5_days if invitation.format_postal?
      validate_motif_of_this_category_is_defined_in_organisations
      validate_referents_are_assigned if invitation.rdv_with_referents?
      validate_follow_up_motifs_are_defined if invitation.rdv_with_referents?
    end

    private

    def validate_invitation_not_already_sent_today
      add_error(message: "Une invitation #{invitation.format} a déjà été envoyée aujourd'hui à cet usager")
      return if invitation.format_postal?

      nil unless invitation_already_sent_today?
    end

    def invitation_already_sent_today?
      follow_up.invitations.where(format: invitation.format).where("created_at > ?", 24.hours.ago).any?
    end

    def validate_user_title_presence
      add_error(message: "La civilité de la personne doit être précisée pour pouvoir envoyer une invitation")
      nil if user.title?
    end

    def validate_organisations_are_not_from_different_departments
      return if organisations.map(&:department_id).uniq == [department_id]

      add_error(message: "Les organisations ne peuvent pas être liés à des départements différents de l'invitation")
    end

    def validate_no_rdv_pending_taken_today
      return if follow_up.participations.none?(&:pending?)

      add_error(message: "Cet usager a déjà un rendez-vous à venir pour ce motif")
    end

    def validate_it_expires_in_more_than_5_days
      return if expires_at > 5.days.from_now

      add_error(message: "La durée de validité de l'invitation pour un courrier doit être supérieure à 5 jours")
    end

    def validate_user_belongs_to_an_org_linked_to_motif_category
      add_error(message:
       "L'usager n'appartient pas ou n'est pas actif \
       dans une organisation qui gère la catégorie #{motif_category_name}")
      nil if user.unarchived_organisations.flat_map(&:motif_categories).include?(motif_category)
    end

    def validate_motif_of_this_category_is_defined_in_organisations
      return if organisations_motifs.map(&:motif_category).include?(motif_category)

      add_error(message: "Aucun motif de la catégorie #{motif_category_name} n'est défini sur RDV-Solidarités")
    end

    def validate_referents_are_assigned
      return if user.referent_ids.any?

      add_error(message: "Un référent doit être assigné au bénéficiaire pour les rdvs avec référents")
    end

    def validate_follow_up_motifs_are_defined
      return if organisations_motifs.any? do |motif|
        motif.follow_up? && motif.motif_category == motif_category
      end

      add_error(
        error_type: "no_follow_up_category",
        attributes: {
          organisation_id: organisations.first.id,
          motif_category_name: motif_category_name
        }
      )
    end

    def organisations_motifs
      @organisations_motifs ||= Motif.includes(:motif_category).where(organisation_id: organisations.map(&:id))
    end

    def validate_help_phone_number_presence
      return if help_phone_number.present?

      organisations_without_phone_number = organisations.select { |orga| orga.phone_number.blank? }
      return if organisations_without_phone_number.empty?

      organisation_names = organisations_without_phone_number.map(&:name).to_sentence(last_word_connector: " et ")
      if organisations_without_phone_number.size > 1
        add_error(message: "Les téléphones de contact des organisations (#{organisation_names}) doivent être indiqués.")
      elsif organisations_without_phone_number.size == 1
        add_error(message: "Le téléphone de contact de l'organisation #{organisation_names} doit être indiqué.")
      end
    end

    def add_error(error_type: "generic", message: nil, attributes: {})
      # Attributes are used to build the error message in the view
      # Error type is used to determine which custom message will be displayed in the view
      if error_type == "generic" && message.blank?
        raise ArgumentError, "Le message est requis pour les erreurs génériques"
      end

      result.errors << {
        error_type: error_type,
        message: message,
        attributes: attributes
      }
    end
  end
end
