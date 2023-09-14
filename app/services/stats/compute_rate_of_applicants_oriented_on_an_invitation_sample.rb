module Stats
  class ComputeRateOfApplicantsOrientedOnAnInvitationSample < BaseService
    def initialize(invitations:)
      @invitations = invitations
    end

    def call
      result.value = compute_rate_of_applicants_oriented_on_an_invitation_sample
    end

    private

    def compute_rate_of_applicants_oriented_on_an_invitation_sample
      (applicants_oriented.count / (
        applicants.count.nonzero? || 1
      ).to_f) * 100
    end

    def invitations_that_led_to_an_orientation
      @invitations.select do |invitation|
        invitation_date = invitation.created_at
        invitation.participations.any? do |participation|
          participation.created_at > invitation_date
        end
      end
    end

    def applicants_oriented
      @applicants_oriented ||=
        Applicant.joins(:invitations).where(invitations: invitations_that_led_to_an_orientation).distinct
    end

    def applicants
      @applicants ||= Applicant.joins(:invitations).where(invitations: @invitations).distinct
    end
  end
end
