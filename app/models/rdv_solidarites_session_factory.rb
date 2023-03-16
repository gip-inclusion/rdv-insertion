class RdvSolidaritesSessionFactory
  class << self
    def create_with(**credentials)
      @credentials = credentials.deep_symbolize_keys
      inclusion_connected? ? session_through_shared_secret : session_through_access_token
    end

    def inclusion_connected?
      @credentials[:inclusion_connected] == true
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
