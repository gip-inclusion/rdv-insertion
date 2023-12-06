module Stats
  module Counters
    class UsersWithRdvTakenInLessThan30Days
      include Counter

      count every: :update_participation,
            if: -> { participation.seen? && participation.user.created_at > participation.created_at - 30.days },
            uniq_by: -> { participation.user_id }
    end
  end
end
