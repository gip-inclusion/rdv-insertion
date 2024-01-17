module RdvSolidaritesApi
  class RetrieveOrganisation < Base
    def initialize(rdv_solidarites_organisation_id:)
      @rdv_solidarites_organisation_id = rdv_solidarites_organisation_id
    end

    def call
      request!
      result.organisation = \
        RdvSolidarites::Organisation.new(rdv_solidarites_response_body["organisation"])
    end

    private

    def rdv_solidarites_response
      @rdv_solidarites_response ||= rdv_solidarites_client.get_organisation(@rdv_solidarites_organisation_id)
    end
  end
end
