module Stats
  module Counters
    class UsersWithRdvSeen
      include Counter

      count every: :update_participation,
            if: -> { participation.seen? },
            uniq_by: -> { participation.user_id }
    end
  end
end
