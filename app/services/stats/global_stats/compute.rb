module Stats
  module GlobalStats
    class Compute < BaseService
      def initialize(stat:)
        @stat = stat
      end

      def call
        result.stat_attributes = global_stats
      end

      private

      def global_stats
        @global_stats ||= {
          users_count: users_count,
          rdvs_count: rdvs_count,
          sent_invitations_count: sent_invitations_count,
          rate_of_no_show_for_invitations: rate_of_no_show_for_invitations,
          rate_of_no_show_for_convocations: rate_of_no_show_for_convocations,
          average_time_between_invitation_and_rdv_in_days: average_time_between_invitation_and_rdv_in_days,
          rate_of_users_oriented_in_less_than_30_days:
            rate_of_users_oriented_in_less_than_30_days,
          rate_of_users_oriented: rate_of_users_oriented,
          rate_of_autonomous_users: rate_of_autonomous_users,
          agents_count: agents_count
        }
      end

      def users_count
        @stat.all_users.count
      end

      def rdvs_count
        @stat.all_participations.count
      end

      def sent_invitations_count
        @stat.invitations_sample.count
      end

      def rate_of_no_show_for_invitations
        scope = @stat.statable || Department.new
        number_of_seen = ::Stats::CounterCache::RateOfNoShowForInvitations.counter_for("seen", scope:)
        number_of_noshow = ::Stats::CounterCache::RateOfNoShowForInvitations.counter_for("noshow", scope:)

        (number_of_noshow / (number_of_seen.nonzero? || 1).to_f) * 100
      end

      def rate_of_no_show_for_convocations
        scope = @stat.statable || Department.new
        number_of_seen = ::Stats::CounterCache::RateOfNoShowForConvocations.counter_for("seen", scope:)
        number_of_noshow = ::Stats::CounterCache::RateOfNoShowForConvocations.counter_for("noshow", scope:)

        (number_of_noshow / (number_of_seen.nonzero? || 1).to_f) * 100
      end

      def average_time_between_invitation_and_rdv_in_days
        ComputeAverageTimeBetweenInvitationAndRdvInDays.call(
          rdv_contexts: @stat.rdv_contexts_with_invitations_and_participations_sample
        ).value
      end

      def rate_of_users_oriented_in_less_than_30_days
        ComputeRateOfUsersWithRdvSeenInLessThanThirtyDays.call(
          users: @stat.users_with_orientation_category_sample
        ).value
      end

      def rate_of_users_oriented
        ComputeRateOfUsersWithRdvSeen.call(
          rdv_contexts: @stat.orientation_rdv_contexts_sample
        ).value
      end

      def rate_of_autonomous_users
        ComputeRateOfAutonomousUsers.call(
          users: @stat.invited_users_sample
        ).value
      end

      def agents_count
        @stat.agents_sample.count
      end
    end
  end
end
