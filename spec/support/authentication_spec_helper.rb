module AuthenticationSpecHelper
  def sign_in(agent)
    request.session[:agent_id] = agent.id
  end

  def set_rdv_solidarites_session
    request.session[:rdv_solidarites] = { client: "client", uid: "johndoe@example.com", access_token: "token" }
  end
end
