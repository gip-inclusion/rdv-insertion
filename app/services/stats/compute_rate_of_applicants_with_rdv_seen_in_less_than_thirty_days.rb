module Stats
  class ComputeRateOfApplicantsWithRdvSeenInLessThanThirtyDays < BaseService
    def initialize(applicants:, for_focused_month: false, date: nil)
      @applicants = applicants
      @for_focused_month = for_focused_month
      @date = date
    end

    def call
      result.data = compute_rate_of_applicants_with_rdv_seen_in_less_than_30_days
    end

    private

    # Rate of applicants with rdv seen in less than 30 days
    def compute_rate_of_applicants_with_rdv_seen_in_less_than_30_days
      (applicants_oriented_in_less_than_30_days.to_a.length / (
        selected_applicants.to_a.length.nonzero? || 1
      ).to_f) * 100
    end

    def applicants_oriented_in_less_than_30_days
      @applicants_oriented_in_less_than_30_days ||=
        selected_applicants.to_a.select do |applicant|
          applicant.rdv_seen_delay_in_days.present? && applicant.rdv_seen_delay_in_days < 30
        end
    end

    def selected_applicants
      @selected_applicants ||= if @for_focused_month
                                 applicants_for_30_days_rdvs_seen_scope_created_during_focused_month
                               else
                                 applicants_for_30_days_rdvs_seen_scope
                               end
    end

    def applicants_for_30_days_rdvs_seen_scope_created_during_focused_month
      @applicants_for_30_days_rdvs_seen_scope_created_during_focused_month ||= \
        applicants_for_30_days_rdvs_seen_scope.where(created_at: @date.all_month)
    end

    # For the rate of applicants with rdv seen in less than 30 days
    # we only consider specific contexts to focus on the first RSA rdv
    def applicants_for_30_days_rdvs_seen_scope
      # Applicants with a right open since at least 30 days
      # & invited in an orientation or accompagnement context
      @applicants_for_30_days_rdvs_seen_scope ||= \
        @applicants.where("applicants.created_at < ?", 30.days.ago)
                   .joins(:rdv_contexts)
                   .where(rdv_contexts: {
                            motif_category: %w[
                              rsa_orientation rsa_orientation_on_phone_platform rsa_accompagnement
                              rsa_accompagnement_social rsa_accompagnement_sociopro
                            ]
                          })
    end
  end
end
