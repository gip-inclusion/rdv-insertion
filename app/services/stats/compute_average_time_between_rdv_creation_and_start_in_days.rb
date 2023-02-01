module Stats
  class ComputeAverageTimeBetweenRdvCreationAndStartInDays < BaseService
    def initialize(rdvs:, for_focused_month: false, date: nil)
      @rdvs = rdvs
      @for_focused_month = for_focused_month
      @date = date
    end

    def call
      result.data = compute_average_time_between_rdv_creation_and_start_in_days
    end

    private

    # Delays between the creation of the rdvs and the rdvs date
    def compute_average_time_between_rdv_creation_and_start_in_days
      cumulated_time_between_rdv_creation_and_starts = 0
      selected_rdvs.to_a.each do |rdv|
        cumulated_time_between_rdv_creation_and_starts += rdv.delay_in_days
      end
      cumulated_time_between_rdv_creation_and_starts / (selected_rdvs.to_a.length.nonzero? || 1).to_f
    end

    def selected_rdvs
      @for_focused_month ? rdvs_created_during_focused_month : @rdvs
    end

    def rdvs_created_during_focused_month
      @rdvs_created_during_focused_month ||= \
        @rdvs.where(created_at: @date.all_month)
    end
  end
end
