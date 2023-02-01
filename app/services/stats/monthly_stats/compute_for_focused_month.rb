module Stats
  module MonthlyStats
    class ComputeForFocusedMonth < BaseService
      def initialize(department_number:, date:)
        @department_number = department_number
        @date = date
      end

      def call
        result.data = stats_attributes_for_focused_month
      end

      private

      def stats_attributes_for_focused_month
        @stats_attributes_for_focused_month ||= {
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
        { @date.strftime("%m/%Y") =>
          created_during_focused_month(records_for_stats[:all_applicants]).count }
      end

      def rdvs_count_for_focused_month
        { @date.strftime("%m/%Y") =>
          created_during_focused_month(records_for_stats[:all_rdvs]).count }
      end

      def sent_invitations_count_for_focused_month
        { @date.strftime("%m/%Y") =>
          records_for_stats[:sent_invitations].where(sent_at: @date.all_month).count }
      end

      def percentage_of_no_show_for_focused_month
        { @date.strftime("%m/%Y") =>
          ComputePercentageOfNoShow.call(
            rdvs: records_for_stats[:relevant_rdvs],
            for_focused_month: true,
            date: @date
          ).data.round }
      end

      def average_time_between_invitation_and_rdv_in_days_for_focused_month
        { @date.strftime("%m/%Y") =>
          ComputeAverageTimeBetweenInvitationAndRdvInDays.call(
            rdv_contexts: records_for_stats[:relevant_rdv_contexts],
            for_focused_month: true,
            date: @date
          ).data.round }
      end

      def average_time_between_rdv_creation_and_start_in_days_for_focused_month
        { @date.strftime("%m/%Y") =>
          ComputeAverageTimeBetweenRdvCreationAndStartInDays.call(
            rdvs: records_for_stats[:relevant_rdvs],
            for_focused_month: true,
            date: @date
          ).data.round }
      end

      def rate_of_applicants_with_rdv_seen_in_less_than_30_days_for_focused_month
        { @date.strftime("%m/%Y") =>
          ComputeRateOfApplicantsWithRdvSeenInLessThanThirtyDays.call(
            applicants: records_for_stats[:relevant_applicants],
            for_focused_month: true,
            date: @date
          ).data.round }
      end

      def rate_of_autonomous_applicants_for_focused_month
        { @date.strftime("%m/%Y") =>
          ComputeRateOfAutonomousApplicants.call(
            applicants: records_for_stats[:relevant_applicants],
            rdvs: records_for_stats[:relevant_rdvs],
            sent_invitations: records_for_stats[:sent_invitations],
            for_focused_month: true,
            date: @date
          ).data.round }
      end

      def records_for_stats
        @records_for_stats = RetrieveRecordsForStatsComputing.call(department_number: @department_number).data
      end

      def created_during_focused_month(data)
        data.where(created_at: @date.all_month)
      end
    end
  end
end
