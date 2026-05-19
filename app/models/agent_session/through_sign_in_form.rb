module AgentSession
  class ThroughSignInForm < Base
    def initialize(session_key: nil, **params)
      super(**params)
      @session_key = session_key
    end

    def valid?
      super && session_key_current?
    end

    def max_duration
      7.days
    end

    private

    def session_key_current?
      @session_key.present? && agent.session_key == @session_key
    end
  end
end
