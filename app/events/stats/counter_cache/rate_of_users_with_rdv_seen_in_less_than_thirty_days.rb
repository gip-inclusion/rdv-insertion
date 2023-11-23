module Stats
  module CounterCache
    class RateOfUsersWithRdvSeenInLessThanThirtyDays
      include EventSubscriber
      include Counter

      catch_events :update_participation_successful, if: lambda { |participation|
        participation.seen? && participation.user.created_at > participation.created_at - 30.days
      }

      def self.value(scope:, month: nil)
        number_of_users = Stats::CounterCache::UsersCreated.value(scope:, month:)
        number_of_users_with_rdv_seen_in_less_than_30_days = number_of_elements_in(scope:, month:)

        (number_of_users_with_rdv_seen_in_less_than_30_days / (
          number_of_users.nonzero? || 1
        ).to_f) * 100
      end

      def identifier
        participation.user_id
      end
    end
  end
end
