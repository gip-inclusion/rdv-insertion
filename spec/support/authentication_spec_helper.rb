module AuthenticationSpecHelper
  def sign_in(agent)
    request.session["agent_auth"] = agent_auth_hash_from_sign_in_form(agent)
  end

  def agent_auth_hash_from_sign_in_form(agent)
    timestamp = Time.zone.now.to_i
    {
      id: agent.id,
      created_at: timestamp,
      origin: "sign_in_form",
      signature: agent.sign_with(timestamp)
    }
  end

  def setup_request_session(agent_auth_hash)
    request.session["agent_auth"] = agent_auth_hash
  end

  def setup_agent_session(agent)
    page.set_rack_session(agent_auth: agent_auth_hash_from_sign_in_form(agent))
  end

  def with_current_agent(agent)
    Current.agent = agent
    yield
  ensure
    Current.agent = nil
  end
end
