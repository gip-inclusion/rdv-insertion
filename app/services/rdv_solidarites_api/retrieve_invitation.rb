module RdvSolidaritesApi
  class RetrieveInvitation < Base
    def initialize(rdv_solidarites_session:, rdv_solidarites_token:)
      @rdv_solidarites_session = rdv_solidarites_session
      @rdv_solidarites_token = rdv_solidarites_token
    end

    def call
      request!
      result.user = RdvSolidarites::User.new(rdv_solidarites_response_body["user"].deep_symbolize_keys)
    end

    private

    def rdv_solidarites_response
      @rdv_solidarites_response ||= rdv_solidarites_client.get_invitation(@rdv_solidarites_token)
    end
  end
end
