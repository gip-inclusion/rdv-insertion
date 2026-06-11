module Creneaux
  class PeriodCalculator
    def initialize(motif_category:, organisations:, from: Time.current)
      @motif_category = motif_category
      @organisations = organisations
      @from = from
    end

    def calculate
      earliest_delay = bookable_motifs.minimum(:min_public_booking_delay)
      latest_delay = bookable_motifs.maximum(:max_public_booking_delay)
      return if earliest_delay.nil? || latest_delay.nil?

      (@from + earliest_delay.seconds)..(@from + latest_delay.seconds)
    end

    private

    def bookable_motifs
      @bookable_motifs ||= Motif.active
                                .bookable_by_everyone_or_invited_users
                                .where(motif_category: @motif_category, organisation: @organisations,
                                       follow_up: false)
    end
  end
end
