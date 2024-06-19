module SignOutHelper
  def sign_out_link
    if agent_impersonated?
      [super_admins_agent_impersonation_path(agent_id: current_agent.id), { method: :delete }]
    elsif logged_with_inclusion_connect?
      [inclusion_connect_sign_out_path, { data: { turbo: false } }]
    else
      [sign_out_path, { method: :delete }]
    end
  end

  def sign_out_button_text
    if agent_impersonated?
      "Revenir à ma session"
    else
      "Se déconnecter"
    end
  end
end
