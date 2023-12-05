module Stats
  module Counters
    class NumberOfAgents
      include Counter

      count every: [:create_agent, :update_agent],
            where: -> { agent.has_logged_in? },
            scopes: -> { [agent.departments, agent.organisations] }
    end
  end
end
