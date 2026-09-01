module RdvSolidaritesAuthentication
  class Oauth
    class MissingCredentials < StandardError; end

    def initialize(agent:)
      @agent = agent
    end

    def headers
      raise MissingCredentials if oauth_token.nil?

      { "Authorization" => "Bearer #{oauth_token.api_token}" }
    end

    def renewable?
      oauth_token.present?
    end

    def renew!
      oauth_token.refresh!(oauth_token.api_token)
    end

    private

    def oauth_token
      @agent.rdv_solidarites_oauth_token
    end
  end
end
