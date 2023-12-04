module Stats
  module Counters
    class UsersWithRdvSeen
      include Counter

      count every: :update_participation,
            where: -> { participation.seen? },
            uniq_by: -> { participation.user_id }
    end
  end
end
