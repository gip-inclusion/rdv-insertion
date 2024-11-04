module SignOutHelper
  def sign_out_link
    if agent_impersonated?
      { url: super_admins_agent_impersonation_path(agent_id: current_agent.id), options: { method: :delete } }
    elsif logged_with_inclusion_connect?
      { url: inclusion_connect_sign_out_path, options: { data: { turbo: false } } }
    elsif logged_with_agent_connect?
      { url: agent_connect_logout_path, options: { data: { turbo: false } } }
    else
      { url: sign_out_path, options: { data: { turbo: false } } }
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
