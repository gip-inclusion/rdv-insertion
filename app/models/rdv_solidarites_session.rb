class RdvSolidaritesSession
  attr_reader :uid, :client, :access_token, :x_agent_auth_signature

  def initialize(uid:, client:, access_token:, x_agent_auth_signature: nil)
    @uid = uid
    @client = client
    @access_token = access_token
    @x_agent_auth_signature = x_agent_auth_signature
  end

  def valid?
    (attributes_for_token_access_present? && token_valid?) ||
      (attributes_for_signature_access_present? && signature_valid?)
  end

  def rdv_solidarites_client
    @rdv_solidarites_client ||= RdvSolidaritesClient.new(rdv_solidarites_session: self)
  end

  def to_h
    {
      uid: @uid,
      client: @client,
      access_token: @access_token
    }
  end

  private

  def attributes_for_token_access_present?
    [@uid, @client, @access_token].all?(&:present?)
  end

  def attributes_for_signature_access_present?
    [@uid, @x_agent_auth_signature].all?(&:present?)
  end

  def token_valid?
    validate_token = rdv_solidarites_client.validate_token
    return false unless validate_token.success?

    response_body = JSON.parse(validate_token.body)
    response_body["data"]["uid"] == @uid
  end

  def signature_valid?
    agent = Agent.find_by(email: @uid)
    payload = {
      id: agent.id,
      first_name: agent.first_name,
      last_name: agent.last_name,
      email: agent.email
    }

    OpenSSL::HMAC.hexdigest("SHA256", ENV.fetch("SHARED_SECRET_FOR_AGENTS_AUTH"), payload.to_json) ==
      @x_agent_auth_signature
  end
end
