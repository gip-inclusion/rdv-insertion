module AuthenticatedControllerConcern
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_agent!
    helper_method :logged_in?, :current_agent
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
    @current_agent ||= Agent.find_by(id: session[:agent_id])
  end

  def rdv_solidarites_session
    @rdv_solidarites_session ||= \
      if inclusion_connected?
        RdvSolidaritesSession.from(inclusion_connect_session)
      else
        RdvSolidaritesSession.from(login_session)
      end
  end

  def inclusion_connected?
    session[:connected_with_inclusionconnect] == true
  end

  def inclusion_connect_session
    @inclusion_connect_session ||= InclusionConnectSession.new(
      uid: session["rdv_solidarites"]["uid"],
      x_agent_auth_signature: session["rdv_solidarites"]["x_agent_auth_signature"]
    )
  end

  def login_session
    @login_session ||= LoginSession.new(
      uid: session["rdv_solidarites"]["uid"],
      access_token: session["rdv_solidarites"]["access_token"],
      client: session["rdv_solidarites"]["client"]
    )
  end
end
