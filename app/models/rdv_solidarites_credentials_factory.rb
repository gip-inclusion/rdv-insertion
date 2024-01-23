class RdvSolidaritesCredentialsFactory
  class << self
    def create_with(**credentials)
      credentials = credentials.deep_symbolize_keys
      if credentials[:inclusion_connected] == true
        build_credentials_with_shared_secret(credentials)
      else
        build_credentials_with_access_token(credentials)
      end
    end

    def build_credentials_with_shared_secret(credentials)
      RdvSolidaritesCredentials::WithSharedSecret.new(
        uid: credentials[:uid],
        x_agent_auth_signature: credentials[:x_agent_auth_signature]
      )
    end

    def build_credentials_with_access_token(credentials)
      RdvSolidaritesCredentials::WithAccessToken.new(
        uid: credentials[:uid],
        client: credentials[:client],
        access_token: credentials[:access_token] || credentials[:"access-token"]
      )
    end
  end
end
