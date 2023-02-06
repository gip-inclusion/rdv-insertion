module Stats
  class ComputeRateOfAutonomousApplicants < BaseService
    def initialize(applicants:, rdvs:)
      @applicants = applicants
      @rdvs = rdvs
    end

    def call
      result.value = compute_rate_of_autonomous_applicants
    end

    private

    # Rate of rdvs taken in autonomy
    def compute_rate_of_autonomous_applicants
      (autonomous_applicants.count / (
        invited_applicants.count.nonzero? || 1
      ).to_f) * 100
    end

    def autonomous_applicants
      @autonomous_applicants ||= invited_applicants.select do |applicant|
        applicant.id.in?(@rdvs.preload(:applicants).select(&:created_by_user?).flat_map(&:applicant_ids))
      end
    end

    def invited_applicants
      @invited_applicants ||= @applicants.with_sent_invitations
    end
  end
end
