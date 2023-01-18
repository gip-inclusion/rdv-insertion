module RdvSolidaritesApi
  class RetrieveOrganisationResources < Base
    def initialize(rdv_solidarites_session:, rdv_solidarites_organisation_id:, resource_name:, additional_args: {})
      @rdv_solidarites_organisation_id = rdv_solidarites_organisation_id
      @rdv_solidarites_session = rdv_solidarites_session
      @additional_args = additional_args
      @resource_name = resource_name
    end

    def call
      result[:"#{pluralized_resource_name}"] = []
      retrieve_resources!
    end

    private

    def retrieve_resources!
      next_page = 1
      loop do
        response = retrieve_resources(next_page)
        handle_failure!(response)
        parsed_reponse_body = JSON.parse(response.body)
        result[:"#{pluralized_resource_name}"] += parsed_reponse_body[pluralized_resource_name].map do |attributes|
          resource_class.new(attributes)
        end
        next_page = parsed_reponse_body.dig("meta", "next_page")
        break unless next_page
      end
    end

    def handle_failure!(response)
      return if response.success?

      parsed_reponse_body = JSON.parse(response.body)
      fail!("Erreur RDV-Solidarités: #{parsed_reponse_body['error_messages']&.join(',')}")
    end

    def retrieve_resources(page)
      rdv_solidarites_client.send(
        client_method_name, *[@rdv_solidarites_organisation_id, page].compact, **@additional_args
      )
    end

    def client_method_name
      :"get_organisation_#{pluralized_resource_name}"
    end

    def pluralized_resource_name
      @resource_name.pluralize
    end

    def resource_class
      "RdvSolidarites::#{@resource_name.capitalize}".constantize
    end
  end
end
