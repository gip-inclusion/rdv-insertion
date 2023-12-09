module Counters
  class RdvsTaken
    include Statisfy::Counter

    count every: :participation_created, decrement_on_destroy: true
  end
end
