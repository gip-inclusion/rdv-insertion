class InclusionConnectSession < RdvSolidaritesSession
  def initialize(uid, x_agent_auth_signature)
    @uid = uid
    @x_agent_auth_signature = x_agent_auth_signature
  end

  def valid?
    required_attributes_present? && signature_valid?
  end

  def to_h
    {
      "uid" => @uid,
      "x_agent_auth_signature" => @x_agent_auth_signature
    }
  end

  private

  def required_attributes_present?
    [@uid, @x_agent_auth_signature].all?(&:present?)
  end

  def signature_valid?
    payload = {
      id: agent.id,
      first_name: agent.first_name,
      last_name: agent.last_name,
      email: agent.email
    }

    OpenSSL::HMAC.hexdigest("SHA256", ENV.fetch("SHARED_SECRET_FOR_AGENTS_AUTH"), payload.to_json) ==
      @x_agent_auth_signature
  end

  def agent
    @agent ||= Agent.find_by(email: @uid)
  end
end
