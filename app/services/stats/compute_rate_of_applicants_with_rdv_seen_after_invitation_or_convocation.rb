module Stats
  class ComputeRateOfApplicantsWithRdvSeenAfterInvitationOrConvocation < BaseService
    def initialize(invitations:, notifications:)
      @invitations = invitations
      @notifications = notifications
    end

    def call
      result.value = compute_rate_of_applicants_with_rdv_seen_after_invitation_or_convocation
    end

    private

    def compute_rate_of_applicants_with_rdv_seen_after_invitation_or_convocation
      (applicants_with_rdv_seen_after_invitation_or_convocation.count / (
        applicants.count.nonzero? || 1
      ).to_f) * 100
    end

    def applicants
      @applicants ||=
        Applicant.where(
          id: @invitations.pluck(:applicant_id) +
              @notifications.joins(:participation).pluck("participation.applicant_id")
        ).distinct
    end

    def applicants_with_rdv_seen_after_invitation_or_convocation
      @applicants_with_rdv_seen_after_invitation_or_convocation ||=
        Applicant.where(
          id: invitations_that_led_to_a_rdv_seen.pluck(:applicant_id) +
              notifications_that_led_to_a_rdv_seen.pluck("participation.applicant_id")
        ).distinct
    end

    def invitations_that_led_to_a_rdv_seen
      @invitations.joins(:participations).where(participations: { status: "seen" }).select do |invitation|
        invitation.participations.any? do |participation|
          participation.created_at > invitation.created_at
        end
      end
    end

    def notifications_that_led_to_a_rdv_seen
      @notifications.joins(:participation).where(participation: { status: "seen" }).select do |notification|
        notification.participation.created_at > notification.created_at
      end
    end
  end
end
