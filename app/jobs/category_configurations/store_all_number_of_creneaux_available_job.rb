module CategoryConfigurations
  class StoreAllNumberOfCreneauxAvailableJob < ApplicationJob
    def perform
      CategoryConfiguration.find_each do |category_configuration|
        CategoryConfigurations::StoreNumberOfCreneauxAvailable.perform_later(category_configuration.id)
      end
    end
  end
end
