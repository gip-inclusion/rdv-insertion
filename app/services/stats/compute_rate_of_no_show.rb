module Stats
  class ComputeRateOfNoShow < BaseService
    def initialize(participations:)
      @participations = participations
    end

    def call
      result.value = compute_rate_of_no_show
    end

    private

    def compute_rate_of_no_show
      (@participations.noshow.size / (@participations.resolved.size.nonzero? || 1).to_f) * 100
    end
  end
end
