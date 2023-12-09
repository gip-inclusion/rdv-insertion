module Counters
  class UsersWithRdvSeen
    include Statisfy::Counter

    count every: :participation_updated,
          if: -> { participation.seen? },
          uniq_by: -> { participation.user_id },
          on_destroy: lambda {
            decrement if Participation.where(user_id: participation.user_id).seen.empty?
          }
  end
end
