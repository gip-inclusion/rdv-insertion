module RdvSolidaritesApi
  class Base < BaseService
    attr_reader :rdv_solidarites_session

    delegate :rdv_solidarites_client, to: :rdv_solidarites_session

    protected

    def rdv_solidarites_response_body
      JSON.parse(rdv_solidarites_response.body)
    end

    def request!
      verify_rdv_solidarites_session!

      result.status = rdv_solidarites_response.status
      return if rdv_solidarites_response.success?

      fail_with_errors
    end

    def fail_with_errors
      fail!("record not found") if rdv_solidarites_response.status == 404

      result.errors << "Erreur RDV-Solidarités: #{rdv_solidarites_response_body['error_messages']&.join(',')}"
      result.error_details = rdv_solidarites_response_body["errors"]
      fail!
    end

    def verify_rdv_solidarites_session!
      if @rdv_solidarites_session.nil?
        Sentry.capture_message("rdv_solidarites_session should not be nil")
        fail!("Impossible d'appeler RDV-Solidarités. L'équipe a été notifée de l'erreur et tente de la résoudre.")
      end

      fail!("La session n'est plus valide. Reconnectez-vous et réessayez") unless @rdv_solidarites_session.valid?
    end

    def rdv_solidarites_response
      raise NotImplementedError
    end
  end
end
