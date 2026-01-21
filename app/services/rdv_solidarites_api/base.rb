module RdvSolidaritesApi
  class Base < BaseService
    delegate :rdv_solidarites_client, to: :Current

    protected

    def rdv_solidarites_response_body
      JSON.parse(rdv_solidarites_response.body)
    end

    def request!
      verify_rdv_solidarites_client!

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

    def verify_rdv_solidarites_client!
      return unless rdv_solidarites_client.nil?

      Sentry.capture_message("rdv_solidarites_client should not be nil")
      fail!("Impossible d'appeler RDV-Solidarités. L'équipe a été notifée de l'erreur et tente de la résoudre.")
    end

    def rdv_solidarites_response
      raise NoMethodError
    end
  end
end
