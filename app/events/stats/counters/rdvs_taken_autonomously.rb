module Stats
  module Counters
    class RdvsTakenAutonomously
      include Counter

      count every: :create_participation,
            where: -> { participation.created_by == "user" },
            uniq_by: -> { participation.user_id }
    end
  end
end
