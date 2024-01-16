module RdvSolidaritesApi
  class UpdateOrganisation < Base
    def initialize(organisation_attributes:, rdv_solidarites_organisation_id:)
      @organisation_attributes = organisation_attributes
      @rdv_solidarites_organisation_id = rdv_solidarites_organisation_id
    end

    def call
      request!
      result.organisation = RdvSolidarites::Organisation.new(rdv_solidarites_response_body["organisation"])
    end

    def rdv_solidarites_response
      @rdv_solidarites_response ||= rdv_solidarites_client.update_organisation(
        @rdv_solidarites_organisation_id, @organisation_attributes
      )
    end
  end
end
