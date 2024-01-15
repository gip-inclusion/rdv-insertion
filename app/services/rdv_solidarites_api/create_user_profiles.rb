module RdvSolidaritesApi
  class CreateUserProfiles < Base
    def initialize(rdv_solidarites_user_id:, rdv_solidarites_organisation_ids:)
      @rdv_solidarites_user_id = rdv_solidarites_user_id
      @rdv_solidarites_organisation_ids = rdv_solidarites_organisation_ids
    end

    def call
      request!
    end

    private

    def rdv_solidarites_response
      @rdv_solidarites_response ||=
        rdv_solidarites_client.create_user_profiles(@rdv_solidarites_user_id, @rdv_solidarites_organisation_ids)
    end
  end
end
