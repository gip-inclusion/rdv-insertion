module Stats
  module CounterCache
    class RateOfAutonomousUsers
      include Counter

      def self.value(scope:, month: nil)
        number_of_autonomous = RdvsTakenAutonomously.value(scope:, month:)
        number_of_agents = RdvsTakenByAgent.value(scope:, month:)
        number_of_prescripteurs = RdvsTakenByPrescripteur.value(scope:, month:)

        total_users = number_of_agents + number_of_prescripteurs + number_of_autonomous

        (number_of_autonomous / (total_users.nonzero? || 1).to_f) * 100
      end
    end
  end
end
