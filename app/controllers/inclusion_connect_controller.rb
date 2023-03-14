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

    @agent = InclusionConnect.find_agent(params[:code], inclusion_connect_callback_url)

    if @agent
      handle_successful_authentication
    else
      Sentry.capture_message("Failed to authenticate agent with InclusionConnect")
      handle_failed_authentication
    end
  end

  private

  def set_session_state_for_inclusion_connect
    session[:ic_state] = Digest::SHA1.hexdigest("InclusionConnect - #{SecureRandom.hex(13)}")
  end

  def handle_successful_authentication
    set_session_credentials_for_inclusion_connect
    redirect_to session.delete(:agent_return_to) || root_path
  end

  def handle_failed_authentication
    flash[:error] = "Nous n'avons pas pu vous authentifier. Contacter le support à l'adresse \
      <data.insertion@beta.gouv.fr> si le problème persiste."
    redirect_to sign_in_path
  end

  def set_session_credentials_for_inclusion_connect
    session[:agent_id] = @agent.id
    session[:rdv_solidarites] = {
      uid: @agent.email,
      x_agent_auth_signature: signature_for_agents_auth_with_shared_secret,
      client: nil,
      access_token: nil
    }
    session[:connected_with_inclusionconnect] = true
  end

  def signature_for_agents_auth_with_shared_secret
    payload = {
      id: @agent.rdv_solidarites_agent_id,
      first_name: @agent.first_name,
      last_name: @agent.last_name,
      email: @agent.email
    }
    OpenSSL::HMAC.hexdigest("SHA256", ENV.fetch("SHARED_SECRET_FOR_AGENTS_AUTH"), payload.to_json)
  end
end
