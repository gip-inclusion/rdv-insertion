module RdvSolidaritesApi
  class CreateUser < Base
    def initialize(user_attributes:, rdv_solidarites_session:)
      @user_attributes = user_attributes
      @rdv_solidarites_session = rdv_solidarites_session
    end

    def call
      create_user_in_rdv_solidarites!
    end

    private

    def create_user_in_rdv_solidarites!
      fail_with_response_errors unless rdv_solidarites_response.success?

      result.rdv_solidarites_user = RdvSolidarites::User.new(rdv_solidarites_response_body["user"])
    end

    def rdv_solidarites_response
      @rdv_solidarites_response ||= rdv_solidarites_client.create_user(@user_attributes)
    end
  end
end
