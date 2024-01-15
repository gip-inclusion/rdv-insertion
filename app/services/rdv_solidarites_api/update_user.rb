module RdvSolidaritesApi
  class UpdateUser < Base
    def initialize(user_attributes:, rdv_solidarites_user_id:)
      @user_attributes = user_attributes
      @rdv_solidarites_user_id = rdv_solidarites_user_id
    end

    def call
      request!
      result.user = RdvSolidarites::User.new(rdv_solidarites_response_body["user"])
    end

    def rdv_solidarites_response
      @rdv_solidarites_response ||= rdv_solidarites_client.update_user(@rdv_solidarites_user_id, @user_attributes)
    end
  end
end
