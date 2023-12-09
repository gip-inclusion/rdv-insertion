module Counters
  class NumberOfAgents
    include Statisfy::Counter

    count every: [:agent_created, :agent_updated],
          if: -> { agent.has_logged_in? },
          scopes: -> { [agent.departments, agent.organisations] },
          decrement_on_destroy: true
  end
end
