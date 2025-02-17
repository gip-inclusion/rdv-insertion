module AgentSession
  class Base
    attr_reader :origin

    def initialize(id:, created_at:, origin:, signature:, **params)
      @agent_id = id
      @created_at = created_at
      @signature = signature
      @origin = origin
      @params = params
    end

    def valid?
      origin_valid? && signature_valid? && !expired?
    end

    def agent
      @agent ||= Agent.find_by(id: @agent_id)
    end

    def impersonated?
      origin == "impersonate"
    end

    private

    def signature_valid?
      agent.present? && agent.signature_valid?(@signature, @created_at)
    end

    def expired?
      Time.zone.now > expires_at
    end

    def created_at
      Time.zone.at(@created_at)
    end

    def expires_at
      if max_duration > 1.day
        # we expire at the beginning of day because we don't want the agent to be logged out in the middle of an action
        (created_at + max_duration).beginning_of_day
      else
        created_at + max_duration
      end
    end

    def max_duration
      raise NoMethodError
    end

    def origin_valid?
      origin == self.class.name.demodulize.underscore.gsub("through_", "")
    end
  end
end
