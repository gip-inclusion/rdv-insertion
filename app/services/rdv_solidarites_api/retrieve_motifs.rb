module RdvSolidaritesApi
  class RetrieveMotifs < Base
    def initialize(rdv_solidarites_session:, organisation:)
      @rdv_solidarites_session = rdv_solidarites_session
      @organisation = organisation
    end

    def call
      request!
      result.motifs = rdv_solidarites_response_body['motifs'].map { RdvSolidarites::Motif.new(_1) }
    end

    private

    def rdv_solidarites_response
      @rdv_solidarites_response ||= rdv_solidarites_client.get_motifs(
        @organisation.rdv_solidarites_organisation_id,
        @organisation.rsa_agents_service_id
      )
    end
  end
end
