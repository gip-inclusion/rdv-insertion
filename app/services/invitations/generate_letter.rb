module Invitations
  class GenerateLetter < BaseService
    def initialize(invitation:)
      @invitation = invitation
    end

    def call
      check_invitation_format!
      check_address!
    end

    private

    def check_invitation_format!
      fail!("Génération d'une lettre alors que le format est #{@invitation.format}") unless @invitation.format_postal?
    end

    def check_address!
      fail!("L'adresse doit être renseignée") if address.blank?
    end

    def address
      applicant.address
    end

    def applicant
      @invitation.applicant
    end
  end
end
