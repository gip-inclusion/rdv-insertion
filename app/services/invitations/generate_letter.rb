module Invitations
  class GenerateLetter < BaseService
    def initialize(invitation:)
      @invitation = invitation
    end

    def call
      check_invitation_format!
      check_address!
      check_messages_configuration!
      generate_letter
    end

    private

    def generate_letter
      @invitation.content = ApplicationController.render(
        template: "letters/invitation_for_#{@invitation.motif_category}",
        layout: "pdf",
        locals: {
          invitation: @invitation,
          department: @invitation.department,
          applicant: applicant,
          organisation: organisation,
          sender_name: sender_name,
          messages_configuration: messages_configuration
        }
      )
    end

    def check_invitation_format!
      fail!("Génération d'une lettre alors que le format est #{@invitation.format}") unless @invitation.format_postal?
    end

    def check_address!
      fail!("L'adresse doit être renseignée") if address.blank?
      fail!("Le format de l'adresse est invalide") if street_address.blank? || zipcode_and_city.blank?
    end

    def check_messages_configuration!
      return if messages_configuration.present? && messages_configuration.direction_names.present?

      fail!("La configuration des courriers pour votre organisation est incomplète")
    end

    def address
      applicant.address
    end

    def street_address
      applicant.street_address
    end

    def zipcode_and_city
      applicant.zipcode_and_city
    end

    def organisation
      (applicant.organisations & @invitation.organisations).last
    end

    def messages_configuration
      @messages_configuration ||= @invitation.messages_configuration
    end

    def applicant
      @invitation.applicant
    end

    def sender_name
      messages_configuration.letter_sender_name || "le Conseil départemental"
    end
  end
end
