class InclusionConnectController < ApplicationController
  skip_before_action :authenticate_agent!
  before_action :handle_invalid_state, only: [:callback], unless: :valid_state?

  def auth
    state = set_session_state
    redirect_to Client::InclusionConnect.auth_path(state, inclusion_connect_callback_url), allow_other_host: true
  end

  def callback
    result = RetrieveInclusionConnectAgentInfos.call(
      code: params[:code], callback_url: inclusion_connect_callback_url
    )
    @agent = result.agent

    if result.errors.empty? && @agent
      set_session_credentials(result)
      redirect_to session.delete(:agent_return_to) || root_path
    else
      handle_failed_authentication(result.errors)
    end
  end

  private

  def set_session_state
    session[:ic_state] = Digest::SHA1.hexdigest("InclusionConnect - #{SecureRandom.hex(13)}")
  end

  def valid_state?
    params[:state] == session[:ic_state]
  end

  def set_session_credentials(result)
    session[:inclusion_connect_token_id] = result.inclusion_connect_token_id
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

  def handle_failed_authentication(errors)
    Sentry.capture_message(errors.join(","))
    flash[:error] = "Nous n'avons pas pu vous authentifier. Contacter le support à l'adresse" \
                    "<data.insertion@beta.gouv.fr> si le problème persiste."
    redirect_to sign_in_path
  end

  def handle_invalid_state
    Sentry.capture_message("Failed to authenticate agent with InclusionConnect : Invalid State")
    flash[:error] = "Nous n'avons pas pu vous authentifier. Contacter le support à l'adresse" \
                    "<data.insertion@beta.gouv.fr> si le problème persiste."
    redirect_to sign_in_path
  end
end
