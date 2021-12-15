module RdvSolidaritesApi
  class Base < BaseService
    attr_reader :rdv_solidarites_session

    delegate :rdv_solidarites_client, to: :rdv_solidarites_session

    protected

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
