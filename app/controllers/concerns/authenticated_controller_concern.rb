module AuthenticatedControllerConcern
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_agent!
    helper_method :current_agent
  end

  private

  def authenticate_agent!
    return if logged_in?

    session[:agent_return_to] = request.env["PATH_INFO"]
    redirect_to sign_in_path
  end

  def logged_in?
    current_agent.present? && rdv_solidarites_session.valid?
  end

  def current_agent
    Current.agent ||= Agent.find_by(id: session[:agent_id])
  end

  def rdv_solidarites_session
    @rdv_solidarites_session ||= RdvSolidaritesSessionFactory.create_with(**session[:rdv_solidarites])
  end
end
