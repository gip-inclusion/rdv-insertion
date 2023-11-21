module Stats
  module CounterCache
    class RdvsTaken
      include EventSubscriber
      include Counter

      catch_events :create_participation_successful

      def scopes
        participation = Participation.find_by(id: params["id"])
        [participation.department, participation.organisation]
      end
    end
  end
end
