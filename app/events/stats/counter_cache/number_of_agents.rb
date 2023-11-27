module Stats
  module CounterCache
    class NumberOfAgents
      include EventSubscriber
      include Counter

      catch_events :create_agent_successful, :update_agent_successful, if: ->(agent) { agent.has_logged_in? }

      def scopes
        [agent.departments.to_a, agent.organisations.to_a].flatten.compact
      end
    end
  end
end
