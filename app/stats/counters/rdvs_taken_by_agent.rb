module Counters
  class RdvsTakenByAgent
    include Statisfy::Counter

    count every: :participation_created,
          if: -> { participation.created_by == "agent" },
          uniq_by: -> { participation.user_id },
          on_destroy: lambda {
            decrement if Participation.where(user_id: participation.user_id, created_by: "agent").empty?
          }
  end
end
