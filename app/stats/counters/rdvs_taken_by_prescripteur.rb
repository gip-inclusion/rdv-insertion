module Counters
  class RdvsTakenByPrescripteur
    include Statisfy::Counter

    count every: :participation_created,
          if: -> { participation.created_by == "prescripteur" },
          uniq_by: -> { participation.user_id },
          on_destroy: lambda {
            decrement if Participation.where(user_id: participation.user_id, created_by: "prescripteur").empty?
          }
  end
end
