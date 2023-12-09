module Counters
  class RdvsTakenAutonomously
    include Statisfy::Counter

    count every: :participation_created,
          if: -> { participation.created_by == "user" },
          uniq_by: -> { participation.user_id },
          on_destroy: lambda {
            decrement if Participation.where(user_id: participation.user_id, created_by: "user").empty?
          }
  end
end
