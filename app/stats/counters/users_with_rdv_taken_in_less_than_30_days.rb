module Counters
  class UsersWithRdvTakenInLessThan30Days
    include Statisfy::Counter

    count every: :participation_updated,
          if: -> { participation.seen? && participation.user.created_at > participation.created_at - 30.days },
          uniq_by: -> { participation.user_id }
  end
end
