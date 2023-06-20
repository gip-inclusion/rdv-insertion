module SetCurrentAgentRolesConcern
  include ActiveSupport::Concern

  private

  def set_current_agent_roles
    @current_agent_roles = AgentRole.where(
      department_level? ? { organisation: @organisations } : { organisation: @organisation }, agent: current_agent
    )
  end
end
