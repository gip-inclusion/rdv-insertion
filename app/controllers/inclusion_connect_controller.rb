class InclusionConnectController < ApplicationController
  skip_before_action :authenticate_agent!

  def auth
    state = set_session_state
    redirect_to InclusionConnectClient.auth_path(state, inclusion_connect_callback_url), allow_other_host: true
  end

  def callback
    return handle_failed_authentication unless valid_state?

    response = InclusionConnectClient.connect(params[:code], inclusion_connect_callback_url)

    if response["error"].nil? && set_session(response)
      redirect_to session.delete(:agent_return_to) || root_path
    else
      handle_failed_authentication
    end
  end

  private

  def set_session_state
    session[:ic_state] = Digest::SHA1.hexdigest("InclusionConnect - #{SecureRandom.hex(13)}")
  end

  def valid_state?
    params[:state] == session[:ic_state]
  end

  def set_session(response)
    # We store id_token from response, we will need this for logging out from inclusion connect
    session[:id_token] = InclusionConnectClient.retrieve_id_token(response)
    # access_token is used for getting agent info from inclusion connect api
    access_token = InclusionConnectClient.retrieve_access_token(response)
    agent_email = InclusionConnectClient.retrieve_agent_email(access_token)
    @agent = Agent.find_by(email: agent_email)
    return false if @agent.blank?

    set_session_credentials
  end

  def set_session_credentials
    session[:agent_id] = @agent.id
    session[:rdv_solidarites] = {
      uid: @agent.email,
      x_agent_auth_signature: signature_for_agents_auth_with_shared_secret,
      inclusion_connected: true
    }
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

  def handle_failed_authentication
    Sentry.capture_message("Failed to authenticate agent with InclusionConnect")
    flash[:error] = "Nous n'avons pas pu vous authentifier. Contacter le support à l'adresse" \
                    "<data.insertion@beta.gouv.fr> si le problème persiste."
    redirect_to sign_in_path
  end
end
