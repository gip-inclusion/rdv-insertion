module Counters
    class UsersWithRdvSeen
      include Statisfy::Counter

      count every: :participation_updated,
            if: -> { participation.seen? },
            uniq_by: -> { participation.user_id }
  end
end
