module AuthenticationSpecHelper
  def sign_in(agent)
    request.session[:agent_id] = agent.id
  end

  def setup_rdv_solidarites_session(session_object)
    request.session["rdv_solidarites"] = {
      "client" => "client", "uid" => "johndoe@example.com", "access_token" => "token"
    }
    allow(RdvSolidaritesSession).to receive(:new)
      .with(client: "client", uid: "johndoe@example.com", access_token: "token")
      .and_return(session_object)
  end
end
