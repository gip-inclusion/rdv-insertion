class AgentSessionFactory
  class << self
    def create_with(**agent_auth)
      agent_auth = agent_auth.deep_symbolize_keys

      session_class = "AgentSession::Through#{agent_auth[:origin]&.camelize}".safe_constantize
      if session_class
        session_class.new(**agent_auth)
      else
        AgentSession::Invalid.new
      end
    end
  end
end
