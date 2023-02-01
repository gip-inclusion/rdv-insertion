module Stats
  module GlobalStats
    class Compute < BaseService
      def initialize(department_number:)
        @department_number = department_number
      end

      def call
        result.data = global_stats_attributes
      end

      private

      def global_stats_attributes
        @global_stats_attributes ||= {
          applicants_count: applicants_count,
          rdvs_count: rdvs_count,
          sent_invitations_count: sent_invitations_count,
          percentage_of_no_show: percentage_of_no_show,
          average_time_between_invitation_and_rdv_in_days: average_time_between_invitation_and_rdv_in_days,
          average_time_between_rdv_creation_and_start_in_days: average_time_between_rdv_creation_and_start_in_days,
          rate_of_applicants_with_rdv_seen_in_less_than_30_days:
            rate_of_applicants_with_rdv_seen_in_less_than_30_days,
          rate_of_autonomous_applicants: rate_of_autonomous_applicants,
          agents_count: agents_count
        }
      end

      def applicants_count
        records_for_stats[:all_applicants].to_a.length
      end

      def rdvs_count
        records_for_stats[:all_rdvs].to_a.length
      end

      def sent_invitations_count
        records_for_stats[:sent_invitations].to_a.length
      end

      def percentage_of_no_show
        ComputePercentageOfNoShow.call(rdvs: records_for_stats[:relevant_rdvs]).data
      end

      def average_time_between_invitation_and_rdv_in_days
        ComputeAverageTimeBetweenInvitationAndRdvInDays.call(
          rdv_contexts: records_for_stats[:relevant_rdv_contexts]
        ).data
      end

      def average_time_between_rdv_creation_and_start_in_days
        ComputeAverageTimeBetweenRdvCreationAndStartInDays.call(rdvs: records_for_stats[:relevant_rdvs]).data
      end

      def rate_of_applicants_with_rdv_seen_in_less_than_30_days
        ComputeRateOfApplicantsWithRdvSeenInLessThanThirtyDays.call(
          applicants: records_for_stats[:relevant_applicants]
        ).data
      end

      def rate_of_autonomous_applicants
        ComputeRateOfAutonomousApplicants.call(
          applicants: records_for_stats[:relevant_applicants],
          rdvs: records_for_stats[:relevant_rdvs],
          sent_invitations: records_for_stats[:sent_invitations]
        ).data
      end

      def agents_count
        records_for_stats[:relevant_agents].to_a.length
      end

      def records_for_stats
        @records_for_stats = RetrieveRecordsForStatsComputing.call(department_number: @department_number).data
      end
    end
  end
end
