module Stats
  module Counters
    class RdvsTakenByAgent
      include Counter

      count every: :create_participation,
            where: -> { participation.created_by == "agent" },
            uniq_by: -> { participation.user_id }
    end
  end
end
