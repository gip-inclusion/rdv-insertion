module Stats
  module CounterCache
    class RdvsTakenByAgent
      include Counter

      catch_events :create_participation_successful, if: ->(participation) { participation.created_by == "agent" }

      def identifier
        participation.user_id
      end
    end
  end
end
