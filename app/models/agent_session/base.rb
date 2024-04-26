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
      origin_valid? && credentials_valid? && !expired?
    end

    def agent
      @agent ||= Agent.find_by(id: @agent_id)
    end

    def impersonate?
      origin == "impersonate"
    end

    def inclusion_connect?
      origin == "inclusion_connect"
    end

    private

    def credentials_valid?
      agent.present? && agent.signature_valid?(@signature, @created_at)
    end

    def expired?
      Time.zone.now > expires_at
    end

    def created_at
      Time.zone.at(@created_at)
    end

    def expires_at
      if duration > 1.day
        # we expire at the end of the day because we don't want the agent to be logged out in the middle of an action
        (created_at + duration).end_of_day
      else
        created_at + duration
      end
    end

    def duration
      raise NoMethodError
    end

    def origin_valid?
      origin == self.class.name.demodulize.underscore.gsub("through_", "")
    end
  end
end
