module Stats
  module MonthlyStats
    class ComputeForFocusedMonth < BaseService
      def initialize(stat:, date:)
        @stat = stat
        @date = date
      end

      def call
        result.stats_values = stats_for_focused_month
      end

      private

      def stats_for_focused_month
        @stats_for_focused_month ||= {
          users_count_grouped_by_month: users_count_for_focused_month,
          rdvs_count_grouped_by_month: rdvs_count_for_focused_month,
          sent_invitations_count_grouped_by_month: sent_invitations_count_for_focused_month,
          rate_of_no_show_for_invitations_grouped_by_month: rate_of_no_show_for_invitations_for_focused_month,
          rate_of_no_show_for_convocations_grouped_by_month: rate_of_no_show_for_notifications_for_focused_month,
          average_time_between_invitation_and_rdv_in_days_by_month:
            average_time_between_invitation_and_rdv_in_days_for_focused_month,
          rate_of_users_with_rdv_seen_in_less_than_30_days_by_month:
            rate_of_users_with_rdv_seen_in_less_than_30_days_for_focused_month,
          rate_of_autonomous_users_grouped_by_month:
            rate_of_autonomous_users_for_focused_month
        }
      end

      def users_count_for_focused_month
        created_during_focused_month(@stat.all_users).count
      end

      def rdvs_count_for_focused_month
        created_during_focused_month(@stat.all_participations).count
      end

      def sent_invitations_count_for_focused_month
        @stat.invitations_sample.where(sent_at: @date.all_month).count
      end

      def rate_of_no_show_for_invitations_for_focused_month
        ComputeRateOfNoShow.call(
          participations: created_during_focused_month(@stat.participations_without_notifications_sample)
        ).value.round
      end

      def rate_of_no_show_for_notifications_for_focused_month
        ComputeRateOfNoShow.call(
          participations: created_during_focused_month(@stat.participations_with_notifications_sample)
        ).value.round
      end

      def average_time_between_invitation_and_rdv_in_days_for_focused_month
        ComputeAverageTimeBetweenInvitationAndRdvInDays.call(
          rdv_contexts: created_during_focused_month(@stat.rdv_contexts_sample)
        ).value.round
      end

      def rate_of_users_with_rdv_seen_in_less_than_30_days_for_focused_month
        ComputeRateOfUsersWithRdvSeenInLessThanThirtyDays.call(
          # we compute the users of the previous month because we want at least 30 days old users
          users: @stat.users_for_30_days_rdvs_seen_sample.where(created_at: (@date - 1.month).all_month)
        ).value.round
      end

      # as long as the "created_by" is not informed on the participation, we exclude from this calculation
      # the rdvs that belong to a collectif motif and the users that do not have at least one non collectif rdv
      def rate_of_autonomous_users_for_focused_month
        ComputeRateOfAutonomousUsers.call(
          users: created_during_focused_month(@stat.invited_users_with_rdvs_non_collectifs_sample)
        ).value.round
      end

      def created_during_focused_month(data)
        data.where(created_at: @date.all_month)
      end
    end
  end
end
