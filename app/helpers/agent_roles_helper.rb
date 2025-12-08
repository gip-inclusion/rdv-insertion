module AgentRolesHelper
  def agent_roles_count_text(admin_count, basic_count)
    "#{admin_roles_count_text(admin_count)}, #{basic_roles_count_text(basic_count)}"
  end

  def basic_roles_count_text(count)
    "#{custom_pluralize(count, 'agent')} #{custom_pluralize(count, 'basique', with_count: false)}"
  end

  def admin_roles_count_text(count)
    "#{custom_pluralize(count, 'agent')} #{custom_pluralize(count, 'administrateur', with_count: false)}"
  end
end
