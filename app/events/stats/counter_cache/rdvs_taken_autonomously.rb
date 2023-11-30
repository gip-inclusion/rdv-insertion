module Stats
  module CounterCache
    class RdvsTakenAutonomously
      include Counter

      catch_events :create_participation_successful, if: ->(participation) { participation.created_by == "user" }

      def identifier
        participation.user_id
      end
    end
  end
end
