module AuthenticationSpecHelper
  def sign_in(agent)
    request.session["agent_auth"] = agent_auth_hash_from_sign_in_form(agent)
  end

  def sign_in_with_inclusion_connect(agent, inclusion_connect_token_id)
    request.session["agent_auth"] = agent_auth_hash_from_inclusion_connect(agent, inclusion_connect_token_id)
  end

  def agent_auth_hash_from_inclusion_connect(agent, inclusion_connect_token_id)
    timestamp = Time.zone.now.to_i
    {
      id: agent.id,
      origin: "inclusion_connect",
      signature: agent.sign_with(timestamp),
      created_at: timestamp,
      inclusion_connect_token_id:
    }
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

    # stub_request(:get, "#{ENV['RDV_SOLIDARITES_URL']}/api/v1/auth/validate_token")
    #   .with(headers: { "Content-Type" => "application/json" }.merge(agent_auth_hash(agent.email)))
    #   .to_return(body: { "data" => { "uid" => agent.email } }.to_json)
  end
end
