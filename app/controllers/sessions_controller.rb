class SessionsController < ApplicationController
  skip_before_action :authenticate_agent!, only: [:create, :destroy]
  wrap_parameters false
  respond_to :json, only: :create
  layout "website"

  override_rate_limit limit: RATE_LIMITS[:sessions], only: [:create]

  before_action :retrieve_agent!, :mark_agent_as_logged_in!, :store_rdv_solidarites_oauth_token!,
                only: [:create]

  def create
    sign_in
    redirect_to root_path
  end

  def destroy
    sign_out
  end

  private

  def retrieve_agent!
    return if authenticated_agent

    flash[:error] = "L'agent ne fait pas partie d'une organisation sur RDV-Insertion. \
                    Déconnectez-vous de RDV Solidarités puis essayez avec un autre compte."
    redirect_to root_path
  end

  def mark_agent_as_logged_in!
    return if authenticated_agent.update(last_sign_in_at: Time.zone.now)

    flash[:error] = authenticated_agent.errors.full_messages
    redirect_to root_path
  end

  def store_rdv_solidarites_oauth_token!
    credentials = request.env["omniauth.auth"]["credentials"]
    authenticated_agent.store_rdv_solidarites_oauth_token!(
      api_token: credentials["token"], refresh_token: credentials["refresh_token"]
    )
  end

  def authenticated_agent
    @authenticated_agent ||= Agent.find_by(email: request.env["omniauth.auth"]["info"]["agent"]["email"])
  end

  def sign_in
    authenticated_agent.generate_session_key!
    clear_session
    set_session_credentials
  end

  def set_session_credentials
    timestamp = Time.zone.now.to_i
    session[:agent_auth] = {
      id: authenticated_agent.id,
      created_at: timestamp,
      origin: "sign_in_form",
      signature: authenticated_agent.sign_with(timestamp),
      session_key: authenticated_agent.session_key
    }
  end

  def sign_out
    session_present = session[:agent_auth].present?
    invalidate_super_admin_authentication_request_if_needed
    rotate_session_key if agent_initiated_sign_out?
    clear_session
    add_flash_notice(session_present) unless agent_initiated_sign_out?
    sign_out_from_rdv_solidarites
  end

  # this is done to invalidate the session cookie when logging out (in case the cookie has been stolen)
  def rotate_session_key
    agent_signing_out&.rotate_session_key!
  end

  def invalidate_super_admin_authentication_request_if_needed
    return unless agent_signing_out&.super_admin?

    agent_signing_out.invalidate_super_admin_authentication_request!
  end

  def agent_signing_out
    agent_impersonated? ? super_admin_impersonating : current_agent
  end

  def agent_initiated_sign_out?
    params[:agent_initiated] == "true"
  end

  def add_flash_notice(session_present)
    # rubocop:disable Rails/ActionControllerFlashBeforeRender
    flash[:notice] =
      session_present ? "Votre session a expirée, veuillez vous reconnecter" : "Veuillez vous connecter"
    # rubocop:enable Rails/ActionControllerFlashBeforeRender
  end

  def sign_out_from_rdv_solidarites
    sign_out_path = OmniAuth::Strategies::RdvServicePublic.sign_out_path(ENV["RDV_SOLIDARITES_OAUTH_APP_ID"])
    redirect_to "#{ENV['RDV_SOLIDARITES_URL']}#{sign_out_path}", allow_other_host: true
  end
end
