module AuthenticatedControllerConcern
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_agent!
    helper_method :current_agent, :agent_impersonated?, :logged_with_inclusion_connect?, :logged_with_agent_connect?
  end

  private

  def authenticate_agent!
    return if logged_in?

    clear_session
    session[:agent_return_to] = request.env["PATH_INFO"]
    redirect_to sign_in_path
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

  def logged_with_inclusion_connect?
    agent_session&.inclusion_connect?
  end

  def logged_with_agent_connect?
    agent_session&.agent_connect?
  end
end
