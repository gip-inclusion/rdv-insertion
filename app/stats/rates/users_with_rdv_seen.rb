module Rates
  class UsersWithRdvSeen
    include Statisfy::Counter

    def self.value(scope: nil, month: nil)
      number_of_users = Counters::UsersWithRdvTaken.value(scope:, month:).nonzero? || 1
      number_of_users_with_rdv_seen = Counters::UsersWithRdvSeen.value(scope:, month:)

      number_of_users_with_rdv_seen / number_of_users.to_f * 100
    end
  end
end
