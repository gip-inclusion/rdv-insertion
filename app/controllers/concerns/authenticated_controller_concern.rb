module AuthenticatedControllerConcern
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_agent!
    rescue_from Pundit::NotAuthorizedError, with: :agent_not_authorized
    helper_method :logged_in?
  end

  private

  def clear_session
    session.delete(:agent_id)
    @current_agent = nil
  end

  def authenticate_agent!
    redirect_to sign_in_path unless logged_in?
  end

  def logged_in?
    !current_agent.nil?
  end

  def current_agent
    @current_agent ||= Agent.includes(:department).find_by(id: session[:agent_id])
  end

  def pundit_user
    current_agent
  end

  def agent_not_authorized
    flash[:alert] = "Votre compte ne vous permet pas d'effectuer cette action"
    redirect_to(request.referrer || root_path)
  end
end
