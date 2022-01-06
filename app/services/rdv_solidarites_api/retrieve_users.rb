module RdvSolidaritesApi
  class RetrieveUsers < Base
    def initialize(rdv_solidarites_session:, user_params: {})
      @rdv_solidarites_session = rdv_solidarites_session
      @user_params = user_params
    end

    def call
      request!
      result.users = rdv_solidarites_response_body['users'].map do |user_attributes|
        RdvSolidarites::User.new(user_attributes)
      end
    end

    private

    def rdv_solidarites_response
      @rdv_solidarites_response ||= rdv_solidarites_client.get_users(@user_params)
    end
  end
end
