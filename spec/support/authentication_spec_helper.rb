module AuthenticationSpecHelper
  def sign_in(agent)
    request.session[:agent_id] = agent.id
  end
end
