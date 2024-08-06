unless Rails.env.test?
  AgentConnect.initialize! do |config|
    config.client_id = ENV["AGENT_CONNECT_CLIENT_ID"]
    config.client_secret = ENV["AGENT_CONNECT_CLIENT_SECRET"]
    config.scope = "openid email"
    config.base_url = ENV["AGENT_CONNECT_BASE_URL"]
    config.algorithm = "RS256"

    config.success_callback = lambda do |user_info|
      agent = Agent.find_by(email: user_info.email)

      if agent && agent.update(
        first_name: callback_client.user_first_name,
        last_name: callback_client.user_last_name,
        last_sign_in_at: Time.zone.from_now
      )
        timestamp = Time.zone.now.to_i
        session[:agent_auth] = {
          id: agent.id,
          origin: "agent_connect",
          signature: agent.sign_with(timestamp),
          created_at: timestamp,
          agent_connect_id_token: user_info.id_token_for_logout
        }
        redirect_to session[:agent_return_to] || root_path
      else
        flash[:error] = "Nous n'avons pas pu vous connecter. Veuillez réessayer."
        redirect_to "/sign_in"
      end
    end

    config.error_callback = lambda do |_|
      flash[:error] = "Nous n'avons pas pu vous connecter. Veuillez réessayer."
      redirect_to "/sign_in"
    end
  end
end
