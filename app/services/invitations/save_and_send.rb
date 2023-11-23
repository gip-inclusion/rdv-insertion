module Invitations
  class SaveAndSend < BaseService
    def initialize(invitation:, rdv_solidarites_session: nil, check_creneaux_availability: true)
      @invitation = invitation
      @rdv_solidarites_session = rdv_solidarites_session
      @check_creneaux_availability = check_creneaux_availability
    end

    def call
      Invitation.with_advisory_lock "invite_user_#{user.id}" do
        assign_link_and_token
        validate_invitation
        verify_creneaux_are_available if @check_creneaux_availability
        save_record!(@invitation)
        send_invitation
        update_invitation_sent_at
      end
      result.invitation = @invitation
    end

    private

    def update_invitation_sent_at
      @invitation.sent_at = Time.zone.now
      save_record!(@invitation)
    end

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

      fail!(
        "L'envoi d'une invitation est impossible car il n'y a plus de créneaux disponibles. " \
        "Nous invitons donc à créer de nouvelles plages d'ouverture depuis l'interface " \
        "RDV-Solidarités pour pouvoir à nouveau envoyer des invitations"
      )
    end

    def retrieve_creneau_availability
      @retrieve_creneau_availability ||= call_service!(
        RdvSolidaritesApi::RetrieveCreneauAvailability,
        rdv_solidarites_session: @rdv_solidarites_session,
        link_params: @invitation.link_params
      )
    end

    def assign_link_and_token
      return if @invitation.link? && @invitation.rdv_solidarites_token?

      call_service!(
        Invitations::AssignAttributes,
        invitation: @invitation,
        rdv_solidarites_session: @rdv_solidarites_session
      )
    end

    def user
      @invitation.user
    end
  end
end
