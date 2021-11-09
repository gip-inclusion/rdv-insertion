module RdvSolidaritesApi
  class RetrieveResources < Base
    def initialize(rdv_solidarites_session:, organisation_id:, resource_name:, additional_args: nil)
      @organisation_id = organisation_id
      @rdv_solidarites_session = rdv_solidarites_session
      @additional_args = additional_args
      @resource_name = resource_name
    end

    def call
      result[:"#{@resource_name}"] = []
      retrieve_resources!
    end

    private

    def retrieve_resources!
      next_page = 1
      loop do
        response = retrieve_resources(next_page)
        handle_failure!(response)
        parsed_reponse_body = JSON.parse(response.body)
        result[:"#{@resource_name}"] += parsed_reponse_body[@resource_name].map { resource_class.new(_1) }
        next_page = parsed_reponse_body.dig('meta', 'next_page')
        break unless next_page
      end
    end

    def handle_failure!(response)
      return if response.success?

      parsed_reponse_body = JSON.parse(response.body)
      fail!("erreur RDV-Solidarités: #{parsed_reponse_body['errors']}")
    end

    def retrieve_resources(page)
      rdv_solidarites_client.send(client_method_name, *client_method_args(page))
    end

    def client_method_args(page)
      [@organisation_id, page].push(@additional_args).compact
    end

    def client_method_name
      :"get_#{@resource_name}"
    end

    def resource_class
      "RdvSolidarites::#{@resource_name.singularize.capitalize}".constantize
    end
  end
end
