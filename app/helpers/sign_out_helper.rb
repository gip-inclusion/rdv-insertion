module SignOutHelper
  def sign_out_link
    if logged_with_inclusion_connect?
      { url: inclusion_connect_sign_out_path, options: { data: { turbo: false } } }
    elsif logged_with_agent_connect?
      { url: agent_connect_logout_path, options: { data: { turbo: false } } }
    else
      { url: sign_out_path, options: { method: :delete } }
    end
  end
end
