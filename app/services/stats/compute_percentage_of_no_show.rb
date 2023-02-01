module Stats
  class ComputePercentageOfNoShow < BaseService
    def initialize(rdvs:, for_focused_month: false, date: nil)
      @rdvs = rdvs
      @for_focused_month = for_focused_month
      @date = date
    end

    def call
      result.data = compute_percentage_of_no_show
    end

    private

    def compute_percentage_of_no_show
      (selected_rdvs.count(&:noshow?) / (selected_rdvs.count(&:resolved?).nonzero? || 1).to_f) * 100
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
