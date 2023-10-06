module RdvSolidaritesApi
  class RetrieveAvailableCreneauxCount < Base
    def initialize(invitation_link_params:, rdv_solidarites_session:)
      @invitation_link_params = invitation_link_params
      @rdv_solidarites_session = rdv_solidarites_session
    end

    def call
      request!
      result.available_creneaux_count = rdv_solidarites_response_body["available_creneaux_count"]
    end

    private

    def rdv_solidarites_response
      @rdv_solidarites_response ||= rdv_solidarites_client.get_available_creneaux_count(@invitation_link_params)
    end
  end
end
