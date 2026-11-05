module AuthenticationSpecHelper
  def sign_in(agent)
    request.session["agent_auth"] = agent_auth_hash_from_sign_in_form(agent)
  end

  # signing in stores the agent oauth token (SessionsController#create), which every RDV-Solidarités call needs
  def agent_auth_hash_from_sign_in_form(agent)
    agent.rdv_solidarites_oauth_token || create(:rdv_solidarites_oauth_token, agent:)
    timestamp = Time.zone.now.to_i
    {
      id: agent.id,
      created_at: timestamp,
      origin: "sign_in_form",
      signature: agent.sign_with(timestamp),
      session_key: agent.session_key
    }
  end

  def setup_request_session(agent_auth_hash)
    request.session["agent_auth"] = agent_auth_hash
  end

  def setup_agent_session(agent)
    page.set_rack_session(agent_auth: agent_auth_hash_from_sign_in_form(agent))
  end
end
