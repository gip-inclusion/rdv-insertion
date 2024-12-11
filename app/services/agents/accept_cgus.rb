module Agents
  class AcceptCgus < BaseService
    def initialize(cgu_accepted:, agent:)
      @cgu_accepted = cgu_accepted
      @agent = agent
    end

    def call
      ensure_cgus_are_accepted
      @agent.update!(cgu_accepted_at: Time.zone.now)
    end

    private

    def ensure_cgus_are_accepted
      return if @cgu_accepted

      fail!("Vous devez accepter les CGUs")
    end
  end
end
