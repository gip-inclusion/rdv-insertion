module Invitations
  class SaveWithLink < BaseService
    def initialize(invitation:, rdv_solidarites_session:)
      @invitation = invitation
      @rdv_solidarites_session = rdv_solidarites_session
    end

    def call
      # we prevent generating two tokens at the same time for one applicant
      Invitation.with_advisory_lock "invite_applicant_#{applicant.id}" do
        @invitation.token = invitation_token
        @invitation.link = invitation_link
        save_record!(@invitation)
      end
    end

    private

    def existing_token
      @existing_token ||= applicant.invitations.last&.token
    end

    def existing_token_valid?
      existing_token.present? && invitation_user.present?
    end

    def invitation_user
      @invitation_user ||= RdvSolidaritesApi::RetrieveInvitation.call(
        token: existing_token,
        rdv_solidarites_session: @rdv_solidarites_session
      ).user
    end

    def applicant
      @invitation.applicant
    end

    def retrieve_invitation_token
      @retrieve_invitation_token ||= call_service!(
        RdvSolidaritesApi::RetrieveInvitationToken,
        rdv_solidarites_user_id: applicant.rdv_solidarites_user_id,
        rdv_solidarites_session: @rdv_solidarites_session
      )
    end

    def invitation_token
      existing_token_valid? ? existing_token : retrieve_invitation_token.invitation_token
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
