module RdvSolidaritesSession
  class Create < BaseService
    def call(credentials)
      @credentials = credentials.symbolize_keys
      result.rdv_solidarites_session = rdv_solidarites_session
    end

    private

    def inclusion_connected?
      @credentials[:inclusion_connected] == true
    end

    def rdv_solidarites_session
      inclusion_connected? ? session_through_shared_secret : session_through_access_token
    end

    def session_through_shared_secret
      RdvSolidaritesSession::WithSharedSecret.new(
        uid: @credentials[:uid],
        x_agent_auth_signature: @credentials[:x_agent_auth_signature]
      )
    end

    def session_through_access_token
      RdvSolidaritesSession::WithAccessToken.new(
        uid: @credentials[:uid],
        client: @credentials[:client],
        access_token: @credentials[:access_token]
      )
    end
  end
end
