module Counters
  class RdvsTakenByAgent
    include Statisfy::Counter

    count every: :participation_created,
          if: -> { participation.created_by == "agent" }
  end
end
