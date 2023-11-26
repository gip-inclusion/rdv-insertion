module RdvSolidaritesApi
  class CreateUserProfiles < Base
    def initialize(rdv_solidarites_session:, user_id:, organisation_ids:)
      @rdv_solidarites_session = rdv_solidarites_session
      @user_id = user_id
      @organisation_ids = organisation_ids
    end

    def call
      request!
    end

    private

    def rdv_solidarites_response
      @rdv_solidarites_response ||= rdv_solidarites_client.create_user_profiles(@user_id, @organisation_ids)
    end
  end
end
