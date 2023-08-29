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
          applicants_count: applicants_count,
          rdvs_count: rdvs_count,
          sent_invitations_count: sent_invitations_count,
          percentage_of_no_show: percentage_of_no_show,
          average_time_between_invitation_and_rdv_in_days: average_time_between_invitation_and_rdv_in_days,
          rate_of_applicants_with_rdv_seen_in_less_than_30_days:
            rate_of_applicants_with_rdv_seen_in_less_than_30_days,
          rate_of_autonomous_applicants: rate_of_autonomous_applicants,
          agents_count: agents_count
        }
      end

      def applicants_count
        @stat.all_applicants.count
      end

      def rdvs_count
        @stat.all_participations.count
      end

      def sent_invitations_count
        @stat.invitations_sample.count
      end

      def percentage_of_no_show
        ComputePercentageOfNoShow.call(participations: @stat.participations_sample).value
      end

      def average_time_between_invitation_and_rdv_in_days
        ComputeAverageTimeBetweenInvitationAndRdvInDays.call(
          rdv_contexts: @stat.rdv_contexts_sample
        ).value
      end

      def rate_of_applicants_with_rdv_seen_in_less_than_30_days
        ComputeRateOfApplicantsWithRdvSeenInLessThanThirtyDays.call(
          applicants: @stat.applicants_for_30_days_rdvs_seen_sample
        ).value
      end

      # as long as the "created_by" is not informed on the participation, we exclude from this calculation
      # the rdvs that belong to a collectif motif and the applicants that do not have at least one non collectif rdv
      def rate_of_autonomous_applicants
        ComputeRateOfAutonomousApplicants.call(
          applicants: @stat.invited_applicants_with_rdvs_non_collectifs_sample
        ).value
      end

      def agents_count
        @stat.agents_sample.count
      end
    end
  end
end
