module AuthenticatedControllerConcern
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_agent!
    helper_method :current_agent
  end

  private

  def authenticate_agent!
    return if logged_in?

    clear_session
    session[:agent_return_to] = request.env["PATH_INFO"]
    redirect_to sign_in_path
  end

  def clear_session
    session.delete(:inclusion_connect_token_id)
    session.delete(:ic_state)
    session.delete(:agent_id)
    session.delete(:rdv_solidarites_credentials)
    @current_agent = nil
  end

  def logged_in?
    current_agent.present? && rdv_solidarites_credentials.valid?
  end

  def current_agent
    Current.agent ||= Agent.find_by(id: session[:agent_id])
  end

  def rdv_solidarites_credentials
    @rdv_solidarites_credentials ||=
      RdvSolidaritesCredentialsFactory.create_with(**session[:rdv_solidarites_credentials])
  end
end
