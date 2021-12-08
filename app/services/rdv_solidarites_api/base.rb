module RdvSolidaritesApi
  class Base < BaseService
    protected

    def rdv_solidarites_client
      @rdv_solidarites_client ||= RdvSolidaritesClient.new(@rdv_solidarites_session)
    end

    def rdv_solidarites_response_body
      JSON.parse(rdv_solidarites_response.body)
    end

    def request!
      return if rdv_solidarites_response.success?

      result.errors << "Erreur RDV-Solidarités: #{rdv_solidarites_response_body['error_messages']&.join(',')}"
      fail!
    end

    def rdv_solidarites_response
      raise NotImplementedError
    end
  end
end
