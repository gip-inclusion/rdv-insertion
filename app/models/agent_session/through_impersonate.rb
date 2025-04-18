module AgentSession
  class ThroughImpersonate < Base
    def max_duration
      1.hour
    end

    def valid?
      super && super_admin_session_coherent? && agent != super_admin_agent
    end

    def super_admin_agent
      @super_admin_agent ||= super_admin_session.agent
    end

    private

    def super_admin_session_coherent?
      # we cannot impersonate while impersonating
      !super_admin_session.impersonated? && super_admin_session.valid? && super_admin_agent.super_admin?
    end

    def super_admin_session
      AgentSessionFactory.create_with(**@params[:super_admin_auth])
    end
  end
end
