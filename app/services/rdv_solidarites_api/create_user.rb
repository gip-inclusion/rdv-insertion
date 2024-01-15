module RdvSolidaritesApi
  class CreateUser < Base
    def initialize(user_attributes:)
      @user_attributes = user_attributes
    end

    def call
      request!
      result.user = RdvSolidarites::User.new(rdv_solidarites_response_body["user"])
    end

    private

    def rdv_solidarites_response
      @rdv_solidarites_response ||= rdv_solidarites_client.create_user(@user_attributes)
    end
  end
end
