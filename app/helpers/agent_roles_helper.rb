module AgentRolesHelper
  def agent_roles_description(agent_roles)
    "#{admin_agent_roles_description(agent_roles.count(&:admin?))}, " \
      "#{basic_agent_roles_description(agent_roles.count(&:basic?))}"
  end

  def basic_agent_roles_description(count)
    "#{custom_pluralize(count, 'agent')} #{custom_pluralize(count, 'basique', with_count: false)}"
  end

  def admin_agent_roles_description(count)
    "#{custom_pluralize(count, 'agent')} #{custom_pluralize(count, 'administrateur', with_count: false)}"
  end
end
