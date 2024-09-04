class AgentConnectController < ApplicationController
  skip_before_action :authenticate_agent!
  after_action(only: :logout) { clear_session }

  def callback
    if authentication.success?
      agent_connect_success
    else
      agent_connect_failure
    end
  end

  private

  def agent_connect_success
    agent = Agent.find_by(email: authentication.user_email)

    if agent&.update(last_sign_in_at: Time.zone.now)
      sign_in(agent)
      redirect_to session[:agent_return_to] || root_path
    else
      flash[:error] = "Il n'y a pas de compte agent pour l'adresse mail #{authentication.user_email}.
        Vous devez utiliser Agent Connect avec l'adresse mail à laquelle vous avez reçu votre invitation"
      redirect_to sign_in_path
    end
  end

  def agent_connect_failure
    flash[:error] = "Nous n'avons pas pu vous connecter. Veuillez réessayer."
    redirect_to sign_in_path
  end

  def sign_in(agent)
    timestamp = Time.zone.now.to_i
    session[:agent_auth] = {
      id: agent.id,
      origin: "agent_connect",
      signature: agent.sign_with(timestamp),
      created_at: timestamp
    }
  end
end
