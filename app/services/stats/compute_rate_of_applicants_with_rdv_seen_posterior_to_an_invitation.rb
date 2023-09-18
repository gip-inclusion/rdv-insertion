module Stats
  class ComputeRateOfApplicantsWithRdvSeenPosteriorToAnInvitation < BaseService
    def initialize(invitations:)
      @invitations = invitations
    end

    def call
      result.value = compute_rate_of_applicants_with_rdv_seen_posterior_to_an_invitation
    end

    private

    def compute_rate_of_applicants_with_rdv_seen_posterior_to_an_invitation
      (applicants_with_rdv_seen_posterior_to_an_invitation.count / (
        applicants.count.nonzero? || 1
      ).to_f) * 100
    end

    def invitations_that_led_to_a_rdv_seen
      @invitations.select do |invitation|
        invitation_date = invitation.created_at
        invitation.participations.seen.any? do |participation|
          participation.created_at > invitation_date
        end
      end
    end

    def applicants_with_rdv_seen_posterior_to_an_invitation
      @applicants_oriented ||=
        Applicant.joins(:invitations).where(invitations: invitations_that_led_to_a_rdv_seen).distinct
    end

    def applicants
      @applicants ||= Applicant.joins(:invitations).where(invitations: @invitations).distinct
    end
  end
end
