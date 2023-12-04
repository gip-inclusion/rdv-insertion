module Stats
  class RateOfAutonomousUsers
    include Counters::Counter

    def self.value(scope:, month: nil)
      number_of_autonomous = Counters::RdvsTakenAutonomously.value(scope:, month:)
      number_of_agents = Counters::RdvsTakenByAgent.value(scope:, month:)
      number_of_prescripteurs = Counters::RdvsTakenByPrescripteur.value(scope:, month:)

      total_users = number_of_agents + number_of_prescripteurs + number_of_autonomous

      (number_of_autonomous / (total_users.nonzero? || 1).to_f) * 100
    end
  end
end
