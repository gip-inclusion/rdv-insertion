module RdvSolidaritesApi
  class UpsertUser < Base
    def initialize(user_attributes:, rdv_solidarites_session:, rdv_solidarites_user_id:)
      @user_attributes = user_attributes
      @rdv_solidarites_session = rdv_solidarites_session
      @rdv_solidarites_user_id = rdv_solidarites_user_id
    end

    def call
      upsert_user_in_rdv_solidarites
    end

    private

    def upsert_user_in_rdv_solidarites
      fail_with_response_errors unless rdv_solidarites_response.success?

      result.rdv_solidarites_user = RdvSolidarites::User.new(rdv_solidarites_response_body["user"])
    end

    def rdv_solidarites_response
      @rdv_solidarites_response ||= if @rdv_solidarites_user_id
                                      rdv_solidarites_client.update_user(@rdv_solidarites_user_id, @user_attributes)
                                    else
                                      rdv_solidarites_client.create_user(@user_attributes)
                                    end
    end
  end
end
