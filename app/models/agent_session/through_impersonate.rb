module AgentSession
  class ThroughImpersonate < Base
    def max_duration
      30.minutes
    end

    def valid?
      super && agent != super_admin_agent
    end

    private

    def credentials_valid?
      super && super_admin_session.valid? && super_admin_agent.super_admin?
    end

    def origin_valid?
      # we cannot impersonate while impersonating
      super && !super_admin_session.impersonate?
    end

    def super_admin_session
      AgentSessionFactory.create_with(**@params[:super_admin_auth])
    end

    def super_admin_agent
      @super_admin_agent ||= super_admin_session.agent
    end
  end
end
