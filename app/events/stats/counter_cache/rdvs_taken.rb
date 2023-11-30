module Stats
  module CounterCache
    class RdvsTaken
      include Counter

      catch_events :create_participation_successful
    end
  end
end
