module Counters
    class RdvsTaken
      include Statisfy::Counter

      count every: :participation_created
  end
end
