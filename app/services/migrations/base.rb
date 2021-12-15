module Migrations
  class Base < BaseService
    def initialize(organisation_id:, rdv_solidarites_session:)
      @organisation_id = organisation_id
      @rdv_solidarites_session = rdv_solidarites_session
    end

    def call
      retrieve_all_resources!
    end

    protected

    def retrieve_all_resources!
      return if retrieve_all_resources.success?

      result.errors += retrieve_all_resources.errors
      fail!
    end

    def rdv_solidarites_resources
      retrieve_all_resources[:"#{resources_name}"]
    end

    def organisation
      @organisation ||= Organisation.includes(:applicants).find(@organisation_id)
    end

    def retrieve_all_resources
      @retrieve_all_resources ||= RdvSolidaritesApi::RetrieveOrganisationResources.call(
        rdv_solidarites_session: @rdv_solidarites_session,
        rdv_solidarites_organisation_id: organisation.rdv_solidarites_organisation_id,
        resource_name: resources_name.singularize
      )
    end

    def resources_name
      self.class.name.demodulize.underscore.split("_").last
    end
  end
end
