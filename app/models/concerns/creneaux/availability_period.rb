module Creneaux
  module AvailabilityPeriod
    extend ActiveSupport::Concern

    def creneaux_available_from
      motifs_with_public_creneaux.earliest_booking_date(from: created_at)
    end

    def creneaux_available_until
      motifs_with_public_creneaux.latest_booking_date(from: created_at)
    end
  end
end
