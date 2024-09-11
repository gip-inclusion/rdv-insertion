module AgentSession
  class ThroughAgentConnect < Base
    def max_duration
      7.days
    end
  end
end
