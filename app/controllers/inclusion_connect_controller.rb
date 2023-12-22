class InclusionConnectController < ApplicationController
  skip_before_action :authenticate_agent!
  before_action :handle_invalid_state, only: [:callback], unless: :valid_state?

  def auth
    state = set_session_state
    redirect_to InclusionConnectClient.auth_path(state, inclusion_connect_callback_url), allow_other_host: true
  end

  def callback
    if retrieve_inclusion_connect_infos.success?
      set_session_credentials
      redirect_to session.delete(:agent_return_to) || root_path
    else
      handle_failed_authentication(retrieve_inclusion_connect_infos.errors.join(", "))
    end
  end

  private

  def retrieve_inclusion_connect_infos
    @retrieve_inclusion_connect_infos ||= RetrieveInclusionConnectAgentInfos.call(
      code: params[:code], callback_url: inclusion_connect_callback_url
    )
  end

  def agent
    retrieve_inclusion_connect_infos.agent
  end

  def inclusion_connect_token_id
    retrieve_inclusion_connect_infos.inclusion_connect_token_id
  end

  def set_session_state
    session[:ic_state] = Digest::SHA1.hexdigest("InclusionConnect - #{SecureRandom.hex(13)}")
  end

  def valid_state?
    ActiveSupport::SecurityUtils.secure_compare(params[:state], session[:ic_state])
  end

  def set_session_credentials
    session[:inclusion_connect_token_id] = inclusion_connect_token_id
    session[:agent_id] = agent.id
    session[:rdv_solidarites] = {
      uid: agent.email,
      x_agent_auth_signature: agent.signature_auth_with_shared_secret,
      inclusion_connected: true
    }
  end

  def handle_failed_authentication(errors)
    Sentry.capture_message(errors)
    flash[:error] = "Nous n'avons pas pu vous authentifier. Contacter le support à l'adresse" \
                    "<data.insertion@beta.gouv.fr> si le problème persiste."
    redirect_to sign_in_path
  end

  def handle_invalid_state
    handle_failed_authentication("Failed to authenticate agent with InclusionConnect : Invalid State")
  end
end
