module Stats
  module CounterCache
    class RdvsTaken
      include EventSubscriber
      include Counter

      catch_events :create_participation_successful
    end
  end
end
