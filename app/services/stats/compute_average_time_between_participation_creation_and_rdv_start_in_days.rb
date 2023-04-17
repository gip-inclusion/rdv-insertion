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
      participations_with_rdvs.find_each do |participation_with_rdv|
        cumulated_time_between_rdv_creation_and_starts += delay_in_days(participation_with_rdv)
      end
      cumulated_time_between_rdv_creation_and_starts / (participations_with_rdvs.size.nonzero? || 1).to_f
    end

    def delay_in_days(participation)
      participation.rdv_starts_at.to_datetime.mjd - participation.created_at.to_datetime.mjd
    end

    def participations_with_rdvs
      @participations_with_rdvs ||= @participations.joins(:rdv)
                                                   .select("participations.id, participations.created_at,
                                                            participations.rdv_id, rdvs.starts_at AS rdv_starts_at")
    end
  end
end
