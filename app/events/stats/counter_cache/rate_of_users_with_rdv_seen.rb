module Stats
  module CounterCache
    class RateOfUsersWithRdvSeen
      include EventSubscriber
      include Counter

      catch_events :update_participation_successful, if: ->(subject) { subject.seen? }

      def self.value(scope:, month: nil)
        number_of_users = Stats::CounterCache::UsersCreated.value(scope:, month:)
        number_of_users_with_rdv_seen = counter_for(scope:, month:)

        (number_of_users_with_rdv_seen / (number_of_users.nonzero? || 1).to_f) * 100
      end

      def identifier
        participation.user_id
      end
    end
  end
end
