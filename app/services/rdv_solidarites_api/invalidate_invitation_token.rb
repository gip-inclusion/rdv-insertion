module RdvSolidaritesApi
  class InvalidateInvitationToken < Base
    def initialize(invitation_token:, rdv_solidarites_session:)
      @invitation_token = invitation_token
      @rdv_solidarites_session = rdv_solidarites_session
    end

    def call
      request!
      result.invitation = RdvSolidarites::User.new(rdv_solidarites_response_body['invitation'].deep_symbolize_keys)
    end

    private

    def rdv_solidarites_response
      @rdv_solidarites_response ||= rdv_solidarites_client.invalidate_invitation_token(@invitation_token)
    end
  end
end
