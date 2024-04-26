module AgentSession
  class ThroughInclusionConnect < Base
    def duration
      7.days
    end

    def inclusion_connect_token_id
      @params[:inclusion_connect_token_id]
    end
  end
end
