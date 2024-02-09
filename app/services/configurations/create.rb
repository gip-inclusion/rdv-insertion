module Configurations
  class Create < BaseService
    def initialize(configuration:)
      @configuration = configuration
    end

    def call
      Configuration.transaction do
        activate_motif_category_on_rdvs_territory
        save_record!(@configuration)
      end
    end

    private

    def activate_motif_category_on_rdvs_territory
      @activate_motif_category_on_rdvs_territory ||= call_service!(
        RdvSolidaritesApi::CreateMotifCategoryTerritory,
        motif_category_short_name: @configuration.motif_category_short_name,
        organisation_id: @configuration.rdv_solidarites_organisation_id
      )
    end
  end
end
