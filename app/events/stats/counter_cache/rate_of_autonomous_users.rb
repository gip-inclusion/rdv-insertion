module Stats
  module CounterCache
    class RateOfAutonomousUsers
      include EventSubscriber
      include Counter

      catch_events :create_participation_successful

      def self.value(scope:, month: nil)
        number_of_autonomous = number_of_elements_in(group: "user", scope:, month:)
        number_of_agents = number_of_elements_in(group: "agent", scope:, month:)
        number_of_prescripteurs = number_of_elements_in(group: "prescripteur", scope:, month:)
        total_users = number_of_agents + number_of_prescripteurs + number_of_autonomous

        (number_of_autonomous / (total_users.nonzero? || 1).to_f) * 100
      end

      def identifier
        participation.user_id
      end

      def process_event
        increment(group: participation.created_by)
      end
    end
  end
end
