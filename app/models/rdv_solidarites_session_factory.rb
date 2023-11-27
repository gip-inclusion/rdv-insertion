class RdvSolidaritesSessionFactory
  class << self
    def create_with(**credentials)
      credentials = credentials.deep_symbolize_keys
      if credentials[:inclusion_connected] == true
        session_through_shared_secret(credentials)
      else
        session_through_access_token(credentials)
      end
    end

    def session_through_shared_secret(credentials)
      RdvSolidaritesSession::WithSharedSecret.new(
        uid: credentials[:uid],
        x_agent_auth_signature: credentials[:x_agent_auth_signature]
      )
    end

    def session_through_access_token(credentials)
      RdvSolidaritesSession::WithAccessToken.new(
        uid: credentials[:uid],
        client: credentials[:client],
        access_token: credentials[:access_token] || credentials[:"access-token"]
      )
    end
  end
end
