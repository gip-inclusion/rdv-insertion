module Stats
  module CounterCache
    class UsersWithRdvTakenInLessThan30Days
      include EventSubscriber
      include Counter

      catch_events :update_participation_successful, if: lambda { |participation|
        participation.seen? && participation.user.created_at > participation.created_at - 30.days
      }

      def identifier
        participation.user_id
      end
    end
  end
end
