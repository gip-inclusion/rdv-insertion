module Stats
  module CounterCache
    class RateOfUsersWithRdvSeenInLessThanThirtyDays
      include Counter

      def self.value(scope:, month: nil)
        number_of_users = UsersWithRdvTaken.value(scope:, month:)
        number_of_users_with_rdv_seen_in_less_than_30_days = UsersWithRdvTakenInLessThan30Days.value(scope:, month:)

        (number_of_users_with_rdv_seen_in_less_than_30_days / (
          number_of_users.nonzero? || 1
        ).to_f) * 100
      end
    end
  end
end
