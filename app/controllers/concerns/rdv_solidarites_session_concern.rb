class RdvSolidarites::InvalidSessionError < StandardError; end

module RdvSolidaritesSessionConcern
  extend ActiveSupport::Concern

  included do
    rescue_from RdvSolidarites::InvalidSessionError, with: :invalid_session
  end

  private

  def validate_session!
    raise RdvSolidarites::InvalidSessionError unless rdv_solidarites_session.valid?
  end

  def rdv_solidarites_session
    if request.headers["X-Agent-Auth-Signature"].present?
      @rdv_solidarites_session ||= RdvSolidaritesSession.new(
        uid: request.headers["uid"],
        client: request.headers["client"],
        access_token: request.headers["access-token"],
        x_agent_auth_signature: request.headers["X-Agent-Auth-Signature"]
      )
    else
      @rdv_solidarites_session ||= RdvSolidaritesSession.new(
        uid: request.headers["uid"],
        client: request.headers["client"],
        access_token: request.headers["access-token"]
      )
    end
  end

  def invalid_session
    render(
      json: { errors: ["Les identifiants de session RDV-Solidarités sont invalides"] },
      status: :unauthorized
    )
  end
end
