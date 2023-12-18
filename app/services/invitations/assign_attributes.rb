module Invitations
  class AssignAttributes < BaseService
    def initialize(invitation:)
      @invitation = invitation
    end

    def call
      @invitation.rdv_solidarites_token = rdv_solidarites_token
      @invitation.link = invitation_link
    end

    private

    def rdv_solidarites_token
      retrieve_rdv_solidarites_token.invitation_token
    end

    def retrieve_rdv_solidarites_token
      @retrieve_rdv_solidarites_token ||= call_service!(
        RdvSolidaritesApi::CreateOrRetrieveInvitationToken,
        rdv_solidarites_user_id: @invitation.user.rdv_solidarites_user_id
      )
    end

    def compute_invitation_link
      @compute_invitation_link ||= call_service!(
        Invitations::ComputeLink,
        invitation: @invitation
      )
    end

    def invitation_link
      compute_invitation_link.invitation_link
    end
  end
end
