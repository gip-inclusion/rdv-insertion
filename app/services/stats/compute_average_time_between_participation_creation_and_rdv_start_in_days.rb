module Stats
  class ComputeAverageTimeBetweenParticipationCreationAndRdvStartInDays < BaseService
    def initialize(participations:)
      @participations = participations
    end

    def call
      result.value = compute_average_time_between_participation_creation_and_rdv_start_in_days
    end

    private

    # Delays between the creation of the rdvs and the rdvs date
    def compute_average_time_between_participation_creation_and_rdv_start_in_days
      cumulated_time_between_rdv_creation_and_starts = 0
      @participations.find_each do |participation|
        cumulated_time_between_rdv_creation_and_starts += delay_in_days(participation)
      end
      cumulated_time_between_rdv_creation_and_starts / (@participations.size.nonzero? || 1).to_f
    end

    def delay_in_days(participation)
      participation.created_at.to_datetime.mjd
      participation.rdv_starts_at.to_datetime.mjd - participation.created_at.to_datetime.mjd
    end
  end
end
