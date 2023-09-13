module Stats
  class ComputeRateOfAutonomousApplicants < BaseService
    def initialize(applicants:)
      @applicants = applicants
    end

    def call
      result.value = compute_rate_of_autonomous_applicants
    end

    private

    # Rate of rdvs taken in autonomy
    def compute_rate_of_autonomous_applicants
      (autonomous_applicants.count / (
        @applicants.count.nonzero? || 1
      ).to_f) * 100
    end

    def autonomous_applicants
      @autonomous_applicants ||= @applicants.joins(:participations).where(participations: { created_by: "user" })
    end
  end
end
