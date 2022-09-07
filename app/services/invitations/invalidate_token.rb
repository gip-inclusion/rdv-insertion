module Invitations
  class InvalidateToken < BaseService
    def initialize(invitation:)
      @invitation = invitation
    end

    def call
      invalidate_token
      @invitation.valid_until = DateTime.now
      save_record!(@invitation)
    end

    private

    def invalidate_token
      @invalidate_token ||= call_service!(
        RdvSolidaritesApi::InvalidateInvitationToken,
        invitation_token: @invitation.token,
        rdv_solidarites_session: @rdv_solidarites_session
      )
    end
  end
end
