module AuthenticatedControllerConcern
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_agent!
    helper_method :logged_in?, :current_agent
  end

  private

  def authenticate_agent!
    set_rdv_solidarites_session_for_inclusion_connected_agents if session[:connected_with_inclusionconnect]
    return if logged_in?

    session[:agent_return_to] = request.env["PATH_INFO"]
    redirect_to sign_in_path
  end

  def logged_in?
    current_agent.present? &&
      (session[:connected_with_inclusionconnect] || rdv_solidarites_session.valid?)
    # ici pas de session valide avec le nouveau systéme car la validité test le token
    # est ce suffisant en terme de sécurité ??
  end

  def current_agent
    @current_agent ||= Agent.find_by(id: session[:agent_id])
  end

  def rdv_solidarites_session
    @rdv_solidarites_session ||= RdvSolidaritesSession.new(
      uid: session["rdv_solidarites"]["uid"],
      access_token: session["rdv_solidarites"]["access_token"],
      client: session["rdv_solidarites"]["client"]
    )
  end

  def signature_for_agents_auth_with_shared_secret
    payload = {
      id: current_agent.rdv_solidarites_agent_id,
      first_name: current_agent.first_name,
      last_name: current_agent.last_name,
      email: current_agent.email
    }
    OpenSSL::HMAC.hexdigest("SHA256", ENV.fetch("SHARED_SECRET_FOR_AGENTS_AUTH"), payload.to_json)
  end

  def set_rdv_solidarites_session_for_inclusion_connected_agents
    @rdv_solidarites_session = RdvSolidaritesSession.new(
      uid: current_agent.email,
      x_agent_auth_signature: signature_for_agents_auth_with_shared_secret
    )
  end
end
