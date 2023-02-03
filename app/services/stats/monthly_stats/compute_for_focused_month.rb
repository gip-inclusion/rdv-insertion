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
          applicants_count_grouped_by_month: applicants_count_for_focused_month,
          rdvs_count_grouped_by_month: rdvs_count_for_focused_month,
          sent_invitations_count_grouped_by_month: sent_invitations_count_for_focused_month,
          percentage_of_no_show_grouped_by_month: percentage_of_no_show_for_focused_month,
          average_time_between_invitation_and_rdv_in_days_by_month:
            average_time_between_invitation_and_rdv_in_days_for_focused_month,
          average_time_between_rdv_creation_and_start_in_days_by_month:
            average_time_between_rdv_creation_and_start_in_days_for_focused_month,
          rate_of_applicants_with_rdv_seen_in_less_than_30_days_by_month:
            rate_of_applicants_with_rdv_seen_in_less_than_30_days_for_focused_month,
          rate_of_autonomous_applicants_grouped_by_month:
            rate_of_autonomous_applicants_for_focused_month
        }
      end

      def applicants_count_for_focused_month
        created_during_focused_month(@stat.all_applicants).count
      end

      def rdvs_count_for_focused_month
        created_during_focused_month(@stat.all_rdvs).count
      end

      def sent_invitations_count_for_focused_month
        @stat.invitations_sample.where(sent_at: @date.all_month).count
      end

      def percentage_of_no_show_for_focused_month
        ComputePercentageOfNoShow.call(
          rdvs: created_during_focused_month(@stat.rdvs_sample)
        ).value.round
      end

      def average_time_between_invitation_and_rdv_in_days_for_focused_month
        ComputeAverageTimeBetweenInvitationAndRdvInDays.call(
          rdv_contexts: created_during_focused_month(@stat.rdv_contexts_sample)
        ).value.round
      end

      def average_time_between_rdv_creation_and_start_in_days_for_focused_month
        ComputeAverageTimeBetweenRdvCreationAndStartInDays.call(
          rdvs: created_during_focused_month(@stat.rdvs_sample)
        ).value.round
      end

      def rate_of_applicants_with_rdv_seen_in_less_than_30_days_for_focused_month
        ComputeRateOfApplicantsWithRdvSeenInLessThanThirtyDays.call(
          applicants: created_during_focused_month(@stat.applicants_for_30_days_rdvs_seen_sample)
        ).value.round
      end

      def rate_of_autonomous_applicants_for_focused_month
        ComputeRateOfAutonomousApplicants.call(
          applicants: created_during_focused_month(@stat.invited_applicants_sample),
          rdvs: @stat.rdvs_created_by_user_sample
        ).value.round
      end

      def created_during_focused_month(data)
        data.where(created_at: @date.all_month)
      end
    end
  end
end
