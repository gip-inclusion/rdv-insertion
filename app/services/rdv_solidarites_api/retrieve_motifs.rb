module RdvSolidaritesApi
  class RetrieveMotifs < Base
    def initialize(rdv_solidarites_session:, organisation:)
      @rdv_solidarites_session = rdv_solidarites_session
      @organisation = organisation
    end

    def call
      retrieve_motifs
    end

    private

    def retrieve_motifs
      if rdv_solidarites_response.success?
        result.motifs = rdv_solidarites_response_body['motifs'].map { RdvSolidarites::Motif.new(_1) }
      else
        result.errors << "Erreur RDV-Solidarités: #{rdv_solidarites_response_body['error_messages']&.join(',')}"
      end
    end

    def rdv_solidarites_response
      @rdv_solidarites_response ||= rdv_solidarites_client.get_motifs(
        @organisation.rdv_solidarites_organisation_id,
        @organisation.rsa_agents_service_id
      )
    end
  end
end
