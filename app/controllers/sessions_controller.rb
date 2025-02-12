class SessionsController < ApplicationController
  skip_before_action :authenticate_agent!, only: [:create]
  wrap_parameters false
  respond_to :json, only: :create

  before_action :retrieve_agent!, :mark_agent_as_logged_in!,
                :set_agent_return_to_url,
                only: [:create]

  def create
    set_session_credentials
    flash[:success] = "Connexion réussie"
    redirect_to @agent_return_to_url || root_path
  end

  def destroy
    # On lit la valeur de la session et on prépare la redirection ici parce qu'il y a un `clear_session` ensuite
    sign_out_path = OmniAuth::Strategies::RdvServicePublic.sign_out_path(ENV["RDV_SOLIDARITES_OAUTH_APP_ID"])
    redirect_to "#{ENV['RDV_SOLIDARITES_URL']}#{sign_out_path}", allow_other_host: true

    clear_session
    flash[:notice] = "Déconnexion réussie" # rubocop:disable Rails/ActionControllerFlashBeforeRender
  end

  private

  def retrieve_agent!
    return if authenticated_agent

    flash[:error] = "L'agent ne fait pas partie d'une organisation sur RDV-Insertion. \
                    Déconnectez-vous de RDV Solidarités puis essayez avec un autre compte."
    redirect_to @agent_return_to_url || root_path
  end

  def mark_agent_as_logged_in!
    return if authenticated_agent.update(last_sign_in_at: Time.zone.now)

    flash[:error] = authenticated_agent.errors.full_messages
    redirect_to @agent_return_to_url || root_path
  end

  def authenticated_agent
    @authenticated_agent ||= Agent.find_by(email: request.env["omniauth.auth"]["info"]["agent"]["email"])
  end

  def set_session_credentials
    clear_session

    timestamp = Time.zone.now.to_i
    session[:agent_auth] = {
      id: authenticated_agent.id,
      created_at: timestamp,
      origin: "sign_in_form",
      signature: authenticated_agent.sign_with(timestamp)
    }
  end

  def set_agent_return_to_url
    @agent_return_to_url = session[:agent_return_to]
  end
end
