module RdvSolidaritesApi
  class InviteUser < Base
    def initialize(rdv_solidarites_session:, rdv_solidarites_user_id:, invite_for: nil)
      @rdv_solidarites_session = rdv_solidarites_session
      @rdv_solidarites_user_id = rdv_solidarites_user_id
      @invite_for = invite_for
    end

    def call
      request!
      result.invitation_token = rdv_solidarites_response_body['invitation_token']
    end

    private

    def rdv_solidarites_response
      @rdv_solidarites_response ||= rdv_solidarites_client.invite_user(@rdv_solidarites_user_id, request_body)
    end

    def request_body
      @invite_for.present? ? { invite_for: @invite_for } : {}
    end
  end
end
