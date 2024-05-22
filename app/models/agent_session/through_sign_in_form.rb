module AgentSession
  class ThroughSignInForm < Base
    def max_duration
      7.days
    end
  end
end
