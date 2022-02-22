module Invitations
  class GenerateLetter < BaseService
    def initialize(invitation:)
      @invitation = invitation
    end

    def call
      check_invitation_format!
      check_address!
      generate_letter
    end

    private

    def generate_letter
      @invitation.content = ApplicationController.render(
        template: "invitations/invitation_letter",
        layout: "pdf.html.erb",
        locals: { invitation: @invitation, department: @invitation.department, applicant: applicant }
      )
    end

    def check_invitation_format!
      fail!("Génération d'une lettre alors que le format est #{@invitation.format}") unless @invitation.format_postal?
    end

    def check_address!
      fail!("L'adresse doit être renseignée") if address.blank?
      fail!(wrong_address_message) if street_address.blank? || zipcode_and_city.blank?
    end

    def wrong_address_message
      "L'adresse n'est pas complète ou elle n'est pas enregistrée correctement.<br/><br/>" \
        "Format attendu&nbsp;:<br/>10 rue de l'envoi 12345 - La Ville"
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

    def applicant
      @invitation.applicant
    end
  end
end
