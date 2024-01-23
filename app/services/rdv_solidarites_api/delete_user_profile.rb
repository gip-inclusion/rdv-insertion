module RdvSolidaritesApi
  class DeleteUserProfile < Base
    def initialize(rdv_solidarites_user_id:, rdv_solidarites_organisation_id:)
      @rdv_solidarites_user_id = rdv_solidarites_user_id
      @rdv_solidarites_organisation_id = rdv_solidarites_organisation_id
    end

    def call
      request!
    end

    private

    def rdv_solidarites_response
      @rdv_solidarites_response ||=
        rdv_solidarites_client.delete_user_profile(@rdv_solidarites_user_id, @rdv_solidarites_organisation_id)
    end
  end
end
