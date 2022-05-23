module AuthenticatedControllerConcern
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_agent!
    rescue_from Pundit::NotAuthorizedError, with: :agent_not_authorized
    helper_method :logged_in?
  end

  private

  def authenticate_agent!
    return if logged_in?

    session[:agent_return_to] = request.env['PATH_INFO']
    redirect_to sign_in_path
  end

  def logged_in?
    !current_agent.nil?
  end

  def current_agent
    @current_agent ||= Agent.includes(:organisations).find_by(id: session[:agent_id])
  end

  def pundit_user
    current_agent
  end

  def agent_not_authorized
    should_return_json? ? render_not_authorized : redirect_not_authorized
  end

  def redirect_not_authorized
    flash[:alert] = "Votre compte ne vous permet pas d'effectuer cette action"
    redirect_to root_url, status: :see_other
  end

  def render_not_authorized
    render(
      status: :forbidden,
      json: {
        errors: ["Votre compte ne vous permet pas d'effectuer cette action"]
      }
    )
  end
end
