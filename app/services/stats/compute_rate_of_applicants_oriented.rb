module Stats
  class ComputeRateOfApplicantsOriented < BaseService
    def initialize(applicants:)
      @applicants = applicants
    end

    def call
      result.value = compute_rate_of_applicants_oriented
    end

    private

    def compute_rate_of_applicants_oriented
      (@applicants.select(&:oriented_in_the_app?).count / (
        @applicants.count.nonzero? || 1
      ).to_f) * 100
    end
  end
end
