module AgentRoles
  class ManageExportAuthorizationsForAnOrganisation < BaseService
    def initialize(organisation:, agent_roles:)
      @organisation = organisation
      @agent_roles_checked_to_be_authorized = agent_roles
    end

    def call
      AgentRole.transaction do
        open_new_export_authorizations
        close_export_authorizations
      end
    end

    private

    def open_new_export_authorizations
      return if agent_roles_to_set_export_authorization_to_true.empty?

      agent_roles_to_set_export_authorization_to_true.update_all(export_authorization: true)
    end

    def close_export_authorizations
      return if agent_roles_to_set_export_authorization_to_false.empty?

      agent_roles_to_set_export_authorization_to_false.update_all(export_authorization: false)
    end

    def agent_roles_to_set_export_authorization_to_true
      @agent_roles_to_set_export_authorization_to_true ||=
        AgentRole.where(
          agent_id: agent_ids_to_authorize_in_department,
          organisation_id: organisation_ids
        )
    end

    def agent_roles_to_set_export_authorization_to_false
      @agent_roles_to_set_export_authorization_to_false ||=
        AgentRole.where(
          agent_id: agent_ids_to_set_export_authorization_to_false_in_department,
          organisation_id: organisation_ids
        )
    end

    def agent_ids_to_authorize_in_department
      @agent_ids_to_authorize_in_department ||=
        (@agent_roles_checked_to_be_authorized - basic_agent_roles_authorized_in_organisation).map(&:agent_id)
    end

    def agent_ids_to_set_export_authorization_to_false_in_department
      @agent_ids_to_set_export_authorization_to_false_in_department ||=
        (basic_agent_roles_authorized_in_organisation - @agent_roles_checked_to_be_authorized).map(&:agent_id)
    end

    def basic_agent_roles_authorized_in_organisation
      @basic_agent_roles_authorized_in_organisation ||= @organisation.agent_roles.basic.with_export_authorization
    end

    def organisation_ids
      @organisation_ids ||= department.organisations.map(&:id)
    end

    def department
      @department ||= @organisation.department
    end
  end
end
