module Stats
  class ComputePercentageOfNoShow < BaseService
    def initialize(participations:)
      @participations = participations
    end

    def call
      result.value = compute_percentage_of_no_show
    end

    private

    def compute_percentage_of_no_show
      (@participations.noshow.count / (@participations.resolved.count.nonzero? || 1).to_f) * 100
    end
  end
end
