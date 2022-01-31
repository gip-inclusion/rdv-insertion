module AuthenticationSpecHelper
  def sign_in(agent)
    request.session[:agent_id] = agent.id
  end

  def session_hash
    { "client" => "client", "uid" => "johndoe@example.com", "access_token" => "token" }
  end

  def setup_rdv_solidarites_session(session_object)
    request.session["rdv_solidarites"] = session_hash
    validate_rdv_solidarites_session(session_object)
  end

  def validate_rdv_solidarites_session(session_object)
    allow(RdvSolidaritesSession).to receive(:new)
      .and_return(session_object)
    allow(session_object).to receive(:valid?)
      .and_return(true)
    allow(session_object).to receive(:to_h)
      .and_return(session_hash)
  end

  def api_auth_headers_for_agent(agent)
    {
      client: "client", uid: agent.email, 'access-token': "token",
      CONTENT_TYPE: "application/json", HTTP_ACCEPT: "application/json"
    }
  end
end
