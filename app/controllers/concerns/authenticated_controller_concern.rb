module AuthenticatedControllerConcern
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_agent!
    helper_method :current_agent, :agent_impersonated?
  end

  private

  def authenticate_agent!
    return if logged_in?

    clear_session
    session[:agent_return_to] = request.env["PATH_INFO"]
    flash[:notice] = "Veuillez vous connecter"
    redirect_to root_path
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
end
