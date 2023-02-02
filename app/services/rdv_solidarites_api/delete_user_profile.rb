module RdvSolidaritesApi
  class DeleteUserProfile < Base
    def initialize(user_id:, organisation_id:, rdv_solidarites_session:)
      @user_id = user_id
      @organisation_id = organisation_id
      @rdv_solidarites_session = rdv_solidarites_session
    end

    def call
      request!
    end

    private

    def rdv_solidarites_response
      @rdv_solidarites_response ||= rdv_solidarites_client.delete_user_profile(@user_id, @organisation_id)
    end
  end
end
