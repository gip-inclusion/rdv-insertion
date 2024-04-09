module AuthenticationSpecHelper
  def sign_in(agent)
    setup_request_session(agent)
    mock_agent_credentials(agent.email)
  end

  def credentials_hash(agent_email)
    { "client" => "someclient", "uid" => agent_email, "access_token" => "sometoken" }.symbolize_keys
  end

  def shared_secret_credentials_hash(agent)
    { "uid" => agent.email, "x_agent_auth_signature" => agent.signature_auth_with_shared_secret }.symbolize_keys
  end

  def setup_request_session(agent)
    request.session["agent_id"] = agent.id
    request.session["agent_credentials"] = credentials_hash(agent.email)
  end

  def setup_agent_session(agent)
    page.set_rack_session(agent_id: agent.id, agent_credentials: credentials_hash(agent.email))

    stub_request(:get, "#{ENV['RDV_SOLIDARITES_URL']}/api/v1/auth/validate_token")
      .with(headers: { "Content-Type" => "application/json" }.merge(credentials_hash(agent.email)))
      .to_return(body: { "data" => { "uid" => agent.email } }.to_json)
  end

  def mock_agent_credentials(agent_email)
    allow(AgentCredentialsFactory).to receive(:create_with)
      .with(**credentials_hash(agent_email))
      .and_return(agent_credentials)
    allow(agent_credentials).to receive_messages(
      valid?: true, uid: agent_email, to_h: credentials_hash(agent_email)
    )
  end

  def agent_credentials
    @agent_credentials ||= instance_double(AgentCredentials::WithAccessToken)
  end
end
