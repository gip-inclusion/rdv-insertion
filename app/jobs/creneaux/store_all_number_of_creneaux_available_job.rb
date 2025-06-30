module Creneaux
  class StoreAllNumberOfCreneauxAvailableJob < ApplicationJob
    def perform
      CategoryConfiguration
        .joins(:organisation)
        .where(rdv_with_referents: false, organisations: { archived_at: nil })
        .find_each do |category_configuration|
        Creneaux::StoreNumberOfCreneauxAvailableJob.perform_later(category_configuration.id)
      end
    end
  end
end
