module Stats
  class ComputeRateOfApplicantsWithRdvSeenInLessThanThirtyDays < BaseService
    def initialize(applicants:)
      @applicants = applicants
    end

    def call
      result.value = compute_rate_of_applicants_with_rdv_seen_in_less_than_30_days
    end

    private

    # Rate of applicants with rdv seen in less than 30 days
    def compute_rate_of_applicants_with_rdv_seen_in_less_than_30_days
      (applicants_oriented_in_less_than_30_days.to_a.length / (
        applicants_created_more_than_30_days_ago.to_a.length.nonzero? || 1
      ).to_f) * 100
    end

    def applicants_oriented_in_less_than_30_days
      @applicants_oriented_in_less_than_30_days ||=
        applicants_created_more_than_30_days_ago.to_a.select do |applicant|
          applicant.rdv_seen_delay_in_days.present? && applicant.rdv_seen_delay_in_days < 30
        end
    end

    def applicants_created_more_than_30_days_ago
      @applicants_created_more_than_30_days_ago ||= @applicants.where("applicants.created_at < ?", 30.days.ago)
    end
  end
end
