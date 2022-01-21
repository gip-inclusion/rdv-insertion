module RdvSolidaritesApi
  class CreateUserProfile < Base
    def initialize(rdv_solidarites_session:, user_id:, organisation_id:)
      @rdv_solidarites_session = rdv_solidarites_session
      @user_id = user_id
      @organisation_id = organisation_id
    end

    def call
      request!
      result.user_profile = rdv_solidarites_response_body["user_profile"]
    end

    private

    def rdv_solidarites_response
      @rdv_solidarites_response ||= rdv_solidarites_client.create_user_profile(@user_id, @organisation_id)
    end
  end
end
