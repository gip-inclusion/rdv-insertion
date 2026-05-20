module AgentSession
  class ThroughSignInForm < Base
    private

    def max_duration
      7.days
    end
  end
end
