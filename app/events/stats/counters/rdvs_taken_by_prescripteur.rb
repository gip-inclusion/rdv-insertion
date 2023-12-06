module Stats
  module Counters
    class RdvsTakenByPrescripteur
      include Counter

      count every: :create_participation,
            if: -> { participation.created_by == "prescripteur" },
            uniq_by: -> { participation.user_id }
    end
  end
end
