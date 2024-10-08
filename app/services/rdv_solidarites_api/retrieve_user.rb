module RdvSolidaritesApi
  class RetrieveUser < Base
    def initialize(rdv_solidarites_user_id:)
      @rdv_solidarites_user_id = rdv_solidarites_user_id
    end

    def call
      request!
      result.user =
        RdvSolidarites::User.new(rdv_solidarites_response_body["user"])
    end

    private

    def rdv_solidarites_response
      @rdv_solidarites_response ||= rdv_solidarites_client.get_user(@rdv_solidarites_user_id)
    end
  end
end
