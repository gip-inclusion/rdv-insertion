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
        @applicants.count.nonzero? || 1
      ).to_f) * 100
    end

    def autonomous_applicants
      @autonomous_applicants ||= @applicants.select do |applicant|
        applicant.id.in?(ids_of_applicants_who_created_rdvs_themselves)
      end
    end

    def ids_of_applicants_who_created_rdvs_themselves
      @ids_of_applicants_who_created_rdvs_themselves ||= \
        @rdvs.joins(:applicants).select(&:created_by_user?).flat_map(&:applicant_ids)
    end
  end
end
