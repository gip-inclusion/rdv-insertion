module AuthenticatedControllerConcern
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_agent!
    helper_method :current_agent, :agent_impersonated?, :logged_in?
  end

  private

  def authenticate_agent!
    return if logged_in?

    sign_out(notice: "Veuillez vous reconnecter")
  end

  def sign_out(flash_messages = {})
    current_agent.invalidate_super_admin_authentication_request! if current_agent&.super_admin?
    clear_session
    flash.merge!(flash_messages)
    sign_out_from_rdv_solidarites
  end

  def sign_out_from_rdv_solidarites
    sign_out_path = OmniAuth::Strategies::RdvServicePublic.sign_out_path(ENV["RDV_SOLIDARITES_OAUTH_APP_ID"])
    redirect_to "#{ENV['RDV_SOLIDARITES_URL']}#{sign_out_path}", allow_other_host: true
  end

  def clear_session
    reset_session
    Current.agent = nil
  end

  def logged_in?
    current_agent.present? && agent_session.valid?
  end

  def current_agent
    Current.agent ||= agent_session&.agent
  end

  def agent_session
    return if session[:agent_auth].blank?

    AgentSessionFactory.create_with(**session[:agent_auth])
  end

  def agent_impersonated?
    agent_session&.impersonated?
  end

  def super_admin_impersonating
    return unless agent_impersonated?

    agent_session.super_admin_agent
  end
end
