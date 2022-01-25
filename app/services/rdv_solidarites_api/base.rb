module RdvSolidaritesApi
  class Base < BaseService
    attr_reader :rdv_solidarites_session

    delegate :rdv_solidarites_client, to: :rdv_solidarites_session

    protected

    def rdv_solidarites_response_body
      JSON.parse(rdv_solidarites_response.body)
    end

    def request!
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

    def rdv_solidarites_response
      raise NotImplementedError
    end
  end
end
