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
      @applicants ||= Applicant.joins(:invitations).where(invitations: @invitations).distinct
    end

    def applicants_with_rdv_seen_after_invitation_or_convocation
      @applicants_with_rdv_seen_after_invitation_or_convocation ||=
        Applicant.where(invitations: invitations_that_led_to_a_rdv_seen)
                 .or(Applicant.where(notifications: notifications_that_led_to_a_rdv_seen))
                 .joins(:invitations, :notifications) # we write the .joins to avoid a know error with .or (https://github.com/rails/rails/issues/24055)
                 .distinct
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
