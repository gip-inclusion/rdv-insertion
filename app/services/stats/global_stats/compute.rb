module Stats
  module GlobalStats
    class Compute
      def initialize(stat:)
        @stat = stat
      end

      def users_count
        @stat.all_users.count
      end

      def users_with_rdv_count
        @stat.user_ids_with_rdv_set.count
      end

      def rdvs_count
        @stat.all_participations.count
      end

      def sent_invitations_count
        @stat.invitations_set.count
      end

      def rate_of_no_show_for_invitations
        ComputeRateOfNoShow.call(participations: @stat.participations_after_invitations_set).value
      end

      def rate_of_no_show_for_convocations
        ComputeRateOfNoShow.call(participations: @stat.participations_with_notifications_set).value
      end

      def rate_of_no_show
        ComputeRateOfNoShow.call(participations: @stat.participations_set).value
      end

      def average_time_between_invitation_and_rdv_in_days
        ComputeAverageTimeBetweenInvitationAndRdvInDays.call(structure: @stat.statable).value
      end

      def rate_of_users_oriented_in_less_than_30_days
        ComputeRateOfRdvSeenInLessThanNDays.call(
          follow_ups: @stat.users_first_orientation_follow_up, number_of_days: 30
        ).value
      end

      def rate_of_users_oriented_in_less_than_15_days
        ComputeRateOfRdvSeenInLessThanNDays.call(
          follow_ups: @stat.users_first_orientation_follow_up, number_of_days: 15
        ).value
      end

      def rate_of_users_oriented
        ComputeRateOfUsersWithRdvSeen.call(
          follow_ups: @stat.orientation_follow_ups_with_invitations
        ).value
      end

      def rate_of_autonomous_users
        ComputeRateOfAutonomousUsers.call(
          users: @stat.invited_users_set
        ).value
      end

      def agents_count
        @stat.agents_set.count
      end
    end
  end
end
