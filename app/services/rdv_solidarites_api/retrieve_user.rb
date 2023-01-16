module RdvSolidaritesApi
  class RetrieveUser < Base
    def initialize(rdv_solidarites_session:, rdv_solidarites_user_id:, rdv_solidarites_organisation_id: nil)
      @rdv_solidarites_session = rdv_solidarites_session
      @rdv_solidarites_user_id = rdv_solidarites_user_id
      @rdv_solidarites_organisation_id = rdv_solidarites_organisation_id
    end

    def call
      request!
      result.user = RdvSolidarites::User.new(rdv_solidarites_response_body["user"].deep_symbolize_keys)
    end

    private

    def rdv_solidarites_response
      @rdv_solidarites_response ||= \
        if @rdv_solidarites_organisation_id.present?
          rdv_solidarites_client.get_organisation_user(@rdv_solidarites_user_id, @rdv_solidarites_organisation_id)
        else
          rdv_solidarites_client.get_user(@rdv_solidarites_user_id)
        end
    end
  end
end
