module RdvSolidaritesApi
  class UpdateUser < Base
    def initialize(user_attributes:, rdv_solidarites_session:, rdv_solidarites_user_id:)
      @user_attributes = user_attributes
      @rdv_solidarites_session = rdv_solidarites_session
      @rdv_solidarites_user_id = rdv_solidarites_user_id
    end

    def call
      update_user_in_rdv_solidarites
    end

    private

    def update_user_in_rdv_solidarites
      if rdv_solidarites_response.success?
        result.rdv_solidarites_user = RdvSolidarites::User.new(rdv_solidarites_response_body["user"])
      else
        result.errors << "Erreur RDV-Solidarités: #{rdv_solidarites_response_body['error_messages']&.join(',')}"
      end
    end

    def rdv_solidarites_response
      @rdv_solidarites_response ||= rdv_solidarites_client.update_user(@rdv_solidarites_user_id, @user_attributes)
    end
  end
end
