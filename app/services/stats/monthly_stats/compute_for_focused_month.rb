module Stats
  module MonthlyStats
    class ComputeForFocusedMonth
      def initialize(stat:, date:)
        @stat = stat
        @date = date
      end

      def users_count_grouped_by_month
        created_during_focused_month(@stat.all_users).count
      end

      def users_with_rdv_count_grouped_by_month
        created_during_focused_month(@stat.user_ids_with_rdv_set).count
      end

      def rdvs_count_grouped_by_month
        created_during_focused_month(@stat.all_participations).count
      end

      def sent_invitations_count_grouped_by_month
        created_during_focused_month(@stat.invitations_set).count
      end

      def rate_of_no_show_for_invitations_grouped_by_month
        ComputeRateOfNoShow.call(
          participations: created_during_focused_month(@stat.participations_after_invitations_set)
        ).value.round
      end

      def rate_of_no_show_for_convocations_grouped_by_month
        ComputeRateOfNoShow.call(
          participations: created_during_focused_month(@stat.participations_with_notifications_set)
        ).value.round
      end

      def rate_of_no_show_grouped_by_month
        ComputeRateOfNoShow.call(
          participations: created_during_focused_month(@stat.participations_set)
        ).value.round
      end

      def average_time_between_invitation_and_rdv_in_days_by_month
        ComputeAverageTimeBetweenInvitationAndRdvInDays.call(
          structure: @stat.statable,
          range: @date.all_month
        ).value.round
      end

      def rate_of_users_oriented_in_less_than_45_days_by_month
        ComputeFollowUpSeenRateWithinDelays.call(
          follow_ups: created_during_focused_month(@stat.users_first_orientation_follow_up),
          target_delay_days: 45
        ).value.round
      end

      def rate_of_users_accompanied_in_less_than_30_days_by_month
        ComputeFollowUpSeenRateWithinDelays.call(
          follow_ups: created_during_focused_month(@stat.users_first_accompaniement_follow_up),
          target_delay_days: 30,
          consider_orientation_rdv_as_start: true
        ).value.round
      end

      def rate_of_users_oriented_grouped_by_month
        ComputeRateOfUsersWithRdvSeen.call(
          follow_ups: created_during_focused_month(@stat.orientation_follow_ups_with_invitations)
        ).value.round
      end

      def rate_of_autonomous_users_grouped_by_month
        ComputeRateOfAutonomousUsers.call(
          users: created_during_focused_month(@stat.invited_users_set)
        ).value.round
      end

      def created_during_focused_month(data)
        data.where(created_at: @date.all_month)
      end
    end
  end
end
