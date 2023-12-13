module Counters
  class RdvsTakenAutonomously
    include Statisfy::Counter

    count every: :participation_created,
          if: -> { participation.created_by == "user" }
  end
end
