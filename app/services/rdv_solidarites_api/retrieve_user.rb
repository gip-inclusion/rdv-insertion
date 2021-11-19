module RdvSolidaritesApi
  class RetrieveUser < Base
    def initialize(rdv_solidarites_session:, rdv_solidarites_user_id:)
      @rdv_solidarites_session = rdv_solidarites_session
      @rdv_solidarites_user_id = rdv_solidarites_user_id
    end

    def call
      retrieve_user
    end

    private

    def retrieve_user
      if rdv_solidarites_response.success?
        result.user = RdvSolidarites::User.new(rdv_solidarites_response_body['user'].deep_symbolize_keys)
      else
        result.errors << "Erreur RDV-Solidarités: #{rdv_solidarites_response_body['error_messages']&.join(',')}"
      end
    end

    def rdv_solidarites_response
      @rdv_solidarites_response ||= rdv_solidarites_client.get_user(@rdv_solidarites_user_id)
    end
  end
end
