module AuthenticationSpecHelper
  def sign_in(agent, for_api: false)
    setup_request_session(agent) unless for_api
    mock_rdv_solidarites_session(agent.email)
  end

  def session_hash(agent_email)
    { "client" => "someclient", "uid" => agent_email, "access_token" => "sometoken" }
  end

  def setup_request_session(agent)
    request.session["agent_id"] = agent.id
    request.session["rdv_solidarites"] = session_hash(agent.email)
  end

  def setup_agent_session(agent)
    page.set_rack_session(agent_id: agent.id, rdv_solidarites: session_hash(agent.email))

    ENV["RDV_SOLIDARITES_URL"] = "http://www.rdv-solidarites-test.localhost"

    stub_request(:get, "#{ENV['RDV_SOLIDARITES_URL']}/api/v1/auth/validate_token")
      .with(headers: { "Content-Type" => "application/json" }.merge(session_hash(agent.email)))
      .to_return(body: { "data" => { "uid" => agent.email } }.to_json)
  end

  # rubocop:disable Metrics/AbcSize
  def mock_rdv_solidarites_session(agent_email)
    allow(RdvSolidaritesSession).to receive(:new)
      .and_return(rdv_solidarites_session)
    allow(rdv_solidarites_session).to receive(:valid?)
      .and_return(true)
    allow(rdv_solidarites_session).to receive(:uid).and_return(agent_email)
    allow(rdv_solidarites_session).to receive(:to_h)
      .and_return(session_hash(agent_email))
  end
  # rubocop:enable Metrics/AbcSize

  def rdv_solidarites_session
    @rdv_solidarites_session ||= instance_double(RdvSolidaritesSession)
  end

  def api_auth_headers_for_agent(agent)
    {
      client: "client", uid: agent.email, "access-token": "token",
      CONTENT_TYPE: "application/json", HTTP_ACCEPT: "application/json"
    }
  end
end
