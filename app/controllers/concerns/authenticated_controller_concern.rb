module AuthenticatedControllerConcern
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_agent!
    helper_method :current_agent, :agent_impersonated?, :logged_in?
  end

  private

  def authenticate_agent!
    return if logged_in?

    if browser_navigation_request?
      redirect_to sign_out_url, status: :see_other
    else
      # in most cases (all turbo requests) we can't do full redirection because of how turbo handles it,
      # so we return a 401 instead and the client will handle the redirect in the event listener in application.js
      head :unauthorized
    end
  end

  def browser_navigation_request?
    request.get? &&
      request.format.html? &&
      request.headers["Sec-Fetch-Mode"] == "navigate" &&
      request.headers["Sec-Fetch-Dest"] == "document"
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
