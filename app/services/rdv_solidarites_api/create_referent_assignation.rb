module RdvSolidaritesApi
  class CreateReferentAssignation < Base
    def initialize(rdv_solidarites_user_id:, rdv_solidarites_agent_id:,
                   rdv_solidarites_client: Current.rdv_solidarites_client)
      @rdv_solidarites_user_id = rdv_solidarites_user_id
      @rdv_solidarites_agent_id = rdv_solidarites_agent_id
      @rdv_solidarites_client = rdv_solidarites_client
    end

    def call
      request!
    end

    private

    def rdv_solidarites_response
      @rdv_solidarites_response ||=
        rdv_solidarites_client.create_referent_assignation(@rdv_solidarites_user_id, @rdv_solidarites_agent_id)
    end
  end
end
