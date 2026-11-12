module Creneaux
  class StoreAllNumberOfCreneauxAvailableJob < ApplicationJob
    queue_as :whenever

    def perform
      CategoryConfiguration
        .joins(:organisation)
        .merge(Organisation.active.with_rdv_solidarites_oauth_agent)
        .where(rdv_with_referents: false)
        .find_each do |category_configuration|
          Creneaux::StoreNumberOfCreneauxAvailableJob.perform_later(category_configuration.id)
      end
    end
  end
end
