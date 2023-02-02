module Stats
  class ComputeAverageTimeBetweenRdvCreationAndStartInDays < BaseService
    def initialize(rdvs:)
      @rdvs = rdvs
    end

    def call
      result.value = compute_average_time_between_rdv_creation_and_start_in_days
    end

    private

    # Delays between the creation of the rdvs and the rdvs date
    def compute_average_time_between_rdv_creation_and_start_in_days
      cumulated_time_between_rdv_creation_and_starts = 0
      @rdvs.to_a.each do |rdv|
        cumulated_time_between_rdv_creation_and_starts += rdv.delay_in_days
      end
      cumulated_time_between_rdv_creation_and_starts / (@rdvs.to_a.length.nonzero? || 1).to_f
    end
  end
end
