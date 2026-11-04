module Creneaux
  class StoreNumberOfCreneauxAvailableJob < ApplicationJob
    sidekiq_options retry: 5, queue: "creneaux"

    def perform(category_configuration_id)
      category_configuration = CategoryConfiguration.joins(organisation: { agents: :rdv_solidarites_oauth_token })
                                                    .find_by(id: category_configuration_id)

      return if category_configuration.blank?

      call_service!(StoreNumberOfCreneauxAvailable, category_configuration:)
    end
  end
end
