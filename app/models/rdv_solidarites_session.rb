class RdvSolidaritesSession
  attr_reader :uid, :client, :access_token
  attr_accessor :x_agent_auth_signature

  def initialize(uid:, client: nil, access_token: nil, x_agent_auth_signature: nil)
    @uid = uid
    @client = client
    @access_token = access_token
    @x_agent_auth_signature = x_agent_auth_signature
  end

  def valid?
    all_attributes_present? && token_valid?
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

  def all_attributes_present?
    [@uid, @client, @access_token].all?(&:present?)
  end

  def token_valid?
    validate_token = rdv_solidarites_client.validate_token
    return false unless validate_token.success?

    response_body = JSON.parse(validate_token.body)
    response_body["data"]["uid"] == @uid
  end
end
