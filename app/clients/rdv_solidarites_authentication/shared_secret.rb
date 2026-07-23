module RdvSolidaritesAuthentication
  class SharedSecret
    def initialize(agent:)
      @agent = agent
    end

    def headers
      { uid: @agent.email, x_agent_auth_signature: signature }
    end

    def renewable?
      false
    end

    private

    def signature
      payload = {
        id: @agent.rdv_solidarites_agent_id,
        first_name: @agent.first_name,
        last_name: @agent.last_name,
        email: @agent.email
      }
      OpenSSL::HMAC.hexdigest("SHA256", ENV.fetch("SHARED_SECRET_FOR_AGENTS_AUTH"), payload.to_json)
    end
  end
end
