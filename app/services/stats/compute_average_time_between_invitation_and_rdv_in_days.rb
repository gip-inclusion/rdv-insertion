module Stats
  class ComputeAverageTimeBetweenInvitationAndRdvInDays < BaseService
    def initialize(rdv_contexts:)
      @rdv_contexts = rdv_contexts
    end

    def call
      result.value = compute_average_time_between_invitation_and_rdv_in_days
    end

    private

    # Delays between the first invitation and the first rdv
    def compute_average_time_between_invitation_and_rdv_in_days
      cumulated_invitation_delays = 0
      @rdv_contexts.to_a.each do |rdv_context|
        cumulated_invitation_delays += rdv_context.time_between_invitation_and_rdv_in_days
      end
      cumulated_invitation_delays / (@rdv_contexts.to_a.length.nonzero? || 1).to_f
    end
  end
end
