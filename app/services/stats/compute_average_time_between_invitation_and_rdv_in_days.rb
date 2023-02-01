module Stats
  class ComputeAverageTimeBetweenInvitationAndRdvInDays < BaseService
    def initialize(rdv_contexts:, for_focused_month: false, date: nil)
      @rdv_contexts = rdv_contexts
      @for_focused_month = for_focused_month
      @date = date
    end

    def call
      result.data = compute_average_time_between_invitation_and_rdv_in_days
    end

    private

    # Delays between the first invitation and the first rdv
    def compute_average_time_between_invitation_and_rdv_in_days
      cumulated_invitation_delays = 0
      selected_rdv_contexts.to_a.each do |rdv_context|
        cumulated_invitation_delays += rdv_context.time_between_invitation_and_rdv_in_days
      end
      cumulated_invitation_delays / (selected_rdv_contexts.to_a.length.nonzero? || 1).to_f
    end

    def selected_rdv_contexts
      @for_focused_month ? rdv_contexts_created_during_focused_month : @rdv_contexts
    end

    def rdv_contexts_created_during_focused_month
      @rdv_contexts_created_during_focused_month ||= \
        @rdv_contexts.where(created_at: @date.all_month)
    end
  end
end
