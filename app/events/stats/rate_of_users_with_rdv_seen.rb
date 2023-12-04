module Stats
  module Counters
    class RateOfUsersWithRdvSeen
      include Counters::Counter

      def self.value(scope:, month: nil)
        number_of_users = Counters::UsersWithRdvTaken.value(scope:, month:)
        number_of_users_with_rdv_seen = Counters::UsersWithRdvSeen.value(scope:, month:)

        (number_of_users_with_rdv_seen / (number_of_users.nonzero? || 1).to_f) * 100
      end
    end
  end
end
