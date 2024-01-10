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
      invitation_delays = []

      @rdv_contexts.find_each do |rdv_context|
        next if rdv_context.time_between_invitation_and_rdv_in_days.negative?

        invitation_delays << rdv_context.time_between_invitation_and_rdv_in_days
      end
      invitation_delays.sum / invitation_delays.size.to_f
    end
  end
end
