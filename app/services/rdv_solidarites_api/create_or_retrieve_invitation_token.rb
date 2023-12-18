module RdvSolidaritesApi
  class CreateOrRetrieveInvitationToken < Base
    def initialize(rdv_solidarites_user_id:)
      @rdv_solidarites_user_id = rdv_solidarites_user_id
    end

    def call
      request!
      result.invitation_token = rdv_solidarites_response_body["invitation_token"]
    end

    private

    def rdv_solidarites_response
      @rdv_solidarites_response ||= rdv_solidarites_client.invite_user(@rdv_solidarites_user_id)
    end
  end
end
