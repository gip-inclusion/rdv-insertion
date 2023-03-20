class RdvSolidarites::InvalidSessionError < StandardError; end

module Agents::SignIn
  extend ActiveSupport::Concern

  included do
    rescue_from RdvSolidarites::InvalidSessionError, with: :invalid_session
  end

  private

  def sign_in_agent!
    validate_session!
    retrieve_agent!
    mark_agent_as_logged_in!
    set_session_credentials unless api?
  end

  def validate_session!
    raise RdvSolidarites::InvalidSessionError unless new_rdv_solidarites_session.valid?
  end

  def new_rdv_solidarites_session
    @new_rdv_solidarites_session ||= RdvSolidaritesSessionFactory.create_with(
      uid: request.headers["uid"],
      client: request.headers["client"],
      access_token: request.headers["access-token"]
    )
  end

  def invalid_session
    render(
      json: { errors: ["Les identifiants de session RDV-Solidarités sont invalides"] },
      status: :unauthorized
    )
  end

  def retrieve_agent!
    return if authenticated_agent

    render json: { success: false, errors: ["L'agent ne fait pas partie d'une organisation sur RDV-Insertion"] },
           status: :unprocessable_entity
  end

  def mark_agent_as_logged_in!
    return if authenticated_agent.has_logged_in? || authenticated_agent.update(has_logged_in: true)

    render json: { success: false, errors: authenticated_agent.errors.full_messages }, status: :unprocessable_entity
  end

  def authenticated_agent
    @authenticated_agent ||= Agent.find_by(email: new_rdv_solidarites_session.uid)
  end

  def set_session_credentials
    session[:agent_id] = authenticated_agent.id
    session[:rdv_solidarites] = {
      client: request.headers["client"],
      uid: request.headers["uid"],
      access_token: request.headers["access-token"]
    }
  end

  def api?
    self.class.module_parents.include?(Api)
  end
end
