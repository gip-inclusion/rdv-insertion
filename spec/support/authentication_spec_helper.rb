module AuthenticationSpecHelper
  def sign_in(agent)
    request.session[:agent_id] = agent.id
    setup_rdv_solidarites_session
  end

  def session_hash
    { "client" => "client", "uid" => "johndoe@example.com", "access_token" => "token" }
  end

  def setup_rdv_solidarites_session
    request.session["rdv_solidarites"] = session_hash
    validate_rdv_solidarites_session
  end

  def validate_rdv_solidarites_session
    allow(RdvSolidaritesSession).to receive(:new)
      .and_return(rdv_solidarites_session)
    allow(rdv_solidarites_session).to receive(:valid?)
      .and_return(true)
    allow(rdv_solidarites_session).to receive(:to_h)
      .and_return(session_hash)
  end

  def rdv_solidarites_session
    @rdv_solidarites_session ||= instance_double(RdvSolidaritesSession)
  end

  def api_auth_headers_for_agent(agent)
    {
      client: "client", uid: agent.email, 'access-token': "token",
      CONTENT_TYPE: "application/json", HTTP_ACCEPT: "application/json"
    }
  end
end
