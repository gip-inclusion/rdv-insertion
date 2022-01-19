module Invitations
  class Save < BaseService
    def initialize(invitation:, rdv_solidarites_session:)
      @invitation = invitation
      @rdv_solidarites_session = rdv_solidarites_session
    end

    def call
      retrieve_invitation_token! unless existing_token_valid?
      @invitation.token = invitation_token

      compute_invitation_link!
      @invitation.link = invitation_link

      save_record!(@invitation)
    end

    private

    def existing_token
      @existing_token ||= applicant.invitations.last&.token
    end

    def existing_token_valid?
      existing_token.present? && invitation_user.present?
    end

    def invitation_user
      @invitation_user ||= RdvSolidaritesApi::RetrieveInvitationUser.call(
        token: existing_token,
        rdv_solidarites_session: @rdv_solidarites_session
      ).user
    end

    def applicant
      @invitation.applicant
    end

    def retrieve_invitation_token!
      call_service!(
        RdvSolidaritesApi::RetrieveInvitationToken,
        rdv_solidarites_user_id: applicant.rdv_solidarites_user_id,
        rdv_solidarites_session: @rdv_solidarites_session
      )
    end

    def invitation_token
      existing_token_valid? ? existing_token : @retrieve_invitation_token_service.invitation_token
    end

    def compute_invitation_link!
      call_service!(
        Invitations::ComputeLink,
        invitation: @invitation
      )
    end

    def invitation_link
      @compute_link_service.invitation_link
    end
  end
end
