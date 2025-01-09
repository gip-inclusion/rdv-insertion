module CategoryConfigurations
  class Create < BaseService
    def initialize(category_configuration:)
      @category_configuration = category_configuration
    end

    def call
      CategoryConfiguration.transaction do
        ensure_motif_category_is_authorized
        save_record!(@category_configuration)
        activate_motif_category_on_rdvs_territory
      end
    end

    private

    def ensure_motif_category_is_authorized
      return if MotifCategoryPolicy.new(nil, @category_configuration.motif_category)
                                   .authorized_for_organisation?(@category_configuration.organisation)

      fail!("La catégorie de motif n'est pas autorisée pour cette organisation")
    end

    def activate_motif_category_on_rdvs_territory
      @activate_motif_category_on_rdvs_territory ||= call_service!(
        RdvSolidaritesApi::CreateMotifCategoryTerritory,
        motif_category_short_name: @category_configuration.motif_category_short_name,
        organisation_id: @category_configuration.rdv_solidarites_organisation_id
      )
    end
  end
end
