module Stats
  class ComputeRateOfApplicantsOriented < BaseService
    def initialize(rdv_contexts:)
      @rdv_contexts = rdv_contexts
    end

    def call
      result.value = compute_rate_of_applicants_oriented
    end

    private

    def compute_rate_of_applicants_oriented
      (oriented_applicants.count / (
        applicants.count.nonzero? || 1
      ).to_f) * 100
    end

    def applicants
      @applicants ||= Applicant.joins(:rdv_contexts).where(rdv_contexts: @rdv_contexts).distinct
    end

    def oriented_applicants
      @oriented_applicants ||= Applicant.joins(:rdv_contexts).where(rdv_contexts: @rdv_contexts.rdv_seen).distinct
    end
  end
end
