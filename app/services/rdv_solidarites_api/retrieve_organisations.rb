module RdvSolidaritesApi
  class RetrieveOrganisations < Base
    EXPECTED_GEO_ATTRIBUTES = %i[department_number city_code street_ban_id].freeze

    def initialize(geo_attributes: {})
      @geo_attributes = geo_attributes
    end

    def call
      request!
      result.organisations = rdv_solidarites_response_body["organisations"].map do |organisation_attributes|
        RdvSolidarites::Organisation.new(organisation_attributes)
      end
    end

    private

    def rdv_solidarites_response
      @rdv_solidarites_response ||= rdv_solidarites_client.get_organisations(
        @geo_attributes.slice(*EXPECTED_GEO_ATTRIBUTES)
      )
    end
  end
end
