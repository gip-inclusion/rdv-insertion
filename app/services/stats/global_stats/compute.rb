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
          rate_of_no_show_for_invitations: rate_of_no_show_for_invitations,
          rate_of_no_show_for_convocations: rate_of_no_show_for_convocations,
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

      def rate_of_no_show_for_invitations
        ComputeRateOfNoShow.call(participations: @stat.participations_without_notifications_sample).value
      end

      def rate_of_no_show_for_convocations
        ComputeRateOfNoShow.call(participations: @stat.participations_with_notifications_sample).value
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

      def rate_of_autonomous_applicants
        ComputeRateOfAutonomousApplicants.call(
          applicants: @stat.invited_applicants_sample
        ).value
      end

      def agents_count
        @stat.agents_sample.count
      end
    end
  end
end
