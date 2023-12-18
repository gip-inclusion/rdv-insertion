module Rates
  class AutonomousUsers
    include Statisfy::Monthly

    def self.value(scope: nil, month: nil)
      number_of_autonomous = Counters::UsersWithRdvTakenAutonomously.value(scope:, month:)
      number_of_agents = Counters::UsersWithRdvTakenByAgent.value(scope:, month:)
      number_of_prescripteurs = Counters::UsersWithRdvTakenByPrescripteur.value(scope:, month:)

      total_users = number_of_agents + number_of_prescripteurs + number_of_autonomous

      (number_of_autonomous / (total_users.nonzero? || 1).to_f) * 100
    end
  end
end
