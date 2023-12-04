module Stats
  module Counters
    class RdvsTaken
      include Counter

      count every: :create_participation
    end
  end
end
