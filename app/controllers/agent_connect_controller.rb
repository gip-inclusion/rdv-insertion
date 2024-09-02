class AgentConnectController < ApplicationController
  def callback
    unless auth.success?
      flash[:error] = "Nous n'avons pas pu vous connecter. Veuillez réessayer."
      return redirect_to sign_in_path
    end

    agent = Agent.find_by(email: auth.user_email)

    if agent&.update(last_sign_in_at: Time.zone.now)
      timestamp = Time.zone.now.to_i
      session[:agent_auth] = {
        id: agent.id,
        origin: "agent_connect",
        signature: agent.sign_with(timestamp),
        created_at: timestamp,
        agent_connect_id_token: auth.id_token_for_logout
      }
      redirect_to session[:agent_return_to] || root_path
    else
      flash[:error] = "Il n'y a pas de compte agent pour l'adresse mail #{auth.user_email}.
        Vous devez utiliser Agent Connect avec l'adresse mail à laquelle vous avez reçu votre invitation"
      redirect_to sign_in_path
    end
  end
end
