module Invitations
  class GenerateLetter < BaseService
    def initialize(invitation:)
      @invitation = invitation
    end

    def call
      check_invitation_format!
      check_address!
      check_letter_configuration!
      generate_letter
    end

    private

    def generate_letter
      @invitation.content = ApplicationController.render(
        template: "letters/invitation_for_#{@invitation.context}",
        layout: "pdf",
        locals: {
          invitation: @invitation,
          department: @invitation.department,
          applicant: applicant,
          organisation: organisation,
          sender_name: sender_name,
          letter_configuration: letter_configuration,
          configuration: configuration
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

    def check_letter_configuration!
      fail!("La configuration des courriers pour votre organisation est incomplète") if letter_configuration.blank?
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
      @invitation.organisations.last
    end

    def letter_configuration
      organisation&.letter_configuration
    end

    def configuration
      organisation.configurations.find_by(context: @invitation.context)
    end

    def applicant
      @invitation.applicant
    end

    def sender_name
      letter_configuration.sender_name || "le Conseil départemental"
    end
  end
end
