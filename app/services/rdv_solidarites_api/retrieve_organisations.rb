module RdvSolidaritesApi
  class RetrieveOrganisations < Base
    def initialize(rdv_solidarites_session:, geo_attributes: {})
      @rdv_solidarites_session = rdv_solidarites_session
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
      @rdv_solidarites_response ||= rdv_solidarites_client.get_organisations(@geo_attributes)
    end
  end
end
