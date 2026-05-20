module AgentSession
  class ThroughImpersonate < Base
    def valid?
      super && super_admin_session_coherent? && super_admin_session.valid?
    end

    def super_admin_agent
      @super_admin_agent ||= super_admin_session.agent
    end

    private

    def max_duration
      1.hour
    end

    def super_admin_session_coherent?
      super_admin_agent.super_admin? &&
        # we cannot impersonate while impersonating
        !super_admin_session.impersonated? &&
        # we cannot impersonate ourselves
        agent != super_admin_agent
    end

    def super_admin_session
      AgentSessionFactory.create_with(**@params[:super_admin_auth])
    end
  end
end
