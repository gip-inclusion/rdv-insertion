module Invitations
  class AssignAttributes < BaseService
    def initialize(invitation:, rdv_solidarites_session:)
      @invitation = invitation
      @rdv_solidarites_session = rdv_solidarites_session
    end

    def call
      recreate_user_on_rdv_solidarites if @invitation.user.rdv_solidarites_user_id.nil?
      @invitation.rdv_solidarites_token = rdv_solidarites_token
      @invitation.link = invitation_link
    end

    private

    def user
      # we reload in case the user had a new invitation attached to it after
      # the invitation has been instantiated
      @invitation.user.reload
    end

    def rdv_solidarites_token
      retrieve_rdv_solidarites_token.invitation_token
    end

    def recreate_user_on_rdv_solidarites
      @recreate_user_on_rdv_solidarites ||= call_service!(
        Users::Save, # saving the user will recreate it on rdv_solidarites
        user: user,
        organisation: user.organisations.first,
        rdv_solidarites_session: @rdv_solidarites_session
      )
    end

    def retrieve_rdv_solidarites_token
      @retrieve_rdv_solidarites_token ||= call_service!(
        RdvSolidaritesApi::CreateOrRetrieveInvitationToken,
        rdv_solidarites_user_id: user.rdv_solidarites_user_id,
        rdv_solidarites_session: @rdv_solidarites_session
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
