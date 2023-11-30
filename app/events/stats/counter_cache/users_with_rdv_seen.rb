module Stats
  module CounterCache
    class UsersWithRdvSeen
      include EventSubscriber
      include Counter

      catch_events :update_participation_successful, if: ->(subject) { subject.seen? }

      def identifier
        participation.user_id
      end
    end
  end
end
