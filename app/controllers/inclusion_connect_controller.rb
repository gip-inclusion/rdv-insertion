class InclusionConnectController < ApplicationController
  skip_before_action :authenticate_agent!

  def auth
    state = set_session_state_for_inclusion_connect
    redirect_to InclusionConnect.auth_path(state, inclusion_connect_callback_url), allow_other_host: true
  end

  def callback
    unless params[:state] == session[:ic_state]
      handle_failed_authentication
      return
    end

    agent = InclusionConnect.agent(params[:code], inclusion_connect_callback_url)

    if agent
      handle_successful_authentication(agent)
    else
      Sentry.capture_message("Failed to authenticate agent with InclusionConnect")
      handle_failed_authentication
    end
  end

  private

  def set_session_state_for_inclusion_connect
    session[:ic_state] = Digest::SHA1.hexdigest("InclusionConnect - #{SecureRandom.hex(13)}")
  end

  def handle_successful_authentication(agent)
    @current_agent = agent
    set_session_credentials_for_inclusion_connect
    session[:connected_with_inclusionconnect] = true
    redirect_to root_path
  end

  def handle_failed_authentication
    flash[:error] = "Nous n'avons pas pu vous authentifier. Contacter le support à l'adresse \
      <data.insertion@beta.gouv.fr> si le problème persiste."
    redirect_to sign_in_path
  end

  def set_session_credentials_for_inclusion_connect
    session[:agent_id] = current_agent.id
    session[:rdv_solidarites] = {
      uid: current_agent.email,
      x_agent_auth_signature: nil,
      client: nil,
      access_token: nil
    }
  end
end
