module Stats
  module CounterCache
    class NumberOfAgents
      include EventSubscriber
      include Counter

      catch_events :create_agent_successful

      def scopes
        [agent.departments.to_a, agent.organisations.to_a].flatten.compact
      end
    end
  end
end
