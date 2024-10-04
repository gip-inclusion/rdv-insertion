module Invitations
  class SaveAndSend < BaseService
    def initialize(invitation:, check_creneaux_availability: true)
      @invitation = invitation
      @check_creneaux_availability = check_creneaux_availability
    end

    def call
      Invitation.transaction do
        assign_link_and_token
        validate_invitation
        verify_creneaux_are_available if @check_creneaux_availability
        save_record!(@invitation)
        send_invitation
      end
      result.invitation = @invitation
    end

    private

    def validate_invitation
      call_service!(Invitations::Validate, invitation: @invitation)
    end

    def send_invitation
      send_to_user = @invitation.send_to_user
      return if send_to_user.success?

      result.errors += send_to_user.errors
      fail!
    end

    def verify_creneaux_are_available
      return if retrieve_creneau_availability.creneau_availability

      add_custom_error("Il n'y a plus de créneaux disponibles pour inviter cet usager",
                       template_name: "no_creneau_available")
      fail!
    end

    def retrieve_creneau_availability
      @retrieve_creneau_availability ||= call_service!(
        RdvSolidaritesApi::RetrieveCreneauAvailability,
        link_params: @invitation.link_params
      )
    end

    def assign_link_and_token
      return if @invitation.link? && @invitation.rdv_solidarites_token?

      call_service!(
        Invitations::AssignLinkAndToken,
        invitation: @invitation
      )
    end

    def user
      @invitation.user
    end
  end
end
