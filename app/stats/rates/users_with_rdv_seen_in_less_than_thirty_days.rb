module Rates
  class UsersWithRdvSeenInLessThanThirtyDays
    include Statisfy::Monthly

    def self.value(scope: nil, month: nil)
      users_count = Counters::UsersWithRdvTaken.value(scope:, month:).nonzero? || 1
      users_with_rdv_in_less_than_30_days_count = Counters::UsersWithRdvTakenInLessThan30Days.value(scope:, month:)

      users_with_rdv_in_less_than_30_days_count / users_count.to_f * 100
    end
  end
end