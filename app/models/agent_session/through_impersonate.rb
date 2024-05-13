module AgentSession
  class ThroughImpersonate < Base
    def max_duration
      30.minutes
    end

    def valid?
      super && agent != super_admin_agent && super_admin_session_coherent?
    end

    private

    def super_admin_session_coherent?
      super_admin_session.valid? && super_admin_agent.super_admin? &&
        !super_admin_session.impersonated? # we cannot impersonate while impersonating
    end

    def super_admin_session
      AgentSessionFactory.create_with(**@params[:super_admin_auth])
    end

    def super_admin_agent
      @super_admin_agent ||= super_admin_session.agent
    end
  end
end
