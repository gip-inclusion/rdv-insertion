module Stats
  module CounterCache
    class UsersWithRdvTaken
      include Counter

      catch_events :create_participation_successful

      def identifier
        participation.user_id
      end
    end
  end
end
