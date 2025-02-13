class RdvSolidaritesCredentials
  attr_reader :uid

  def initialize(uid:, client:, access_token:)
    @uid = uid
    @client = client
    @access_token = access_token
  end

  def valid?
    required_attributes_present? && token_valid?
  end

  def email
    @uid
  end

  private

  def required_attributes_present?
    [@uid, @client, @access_token].all?(&:present?)
  end

  def token_valid?
    validate_token = rdv_solidarites_client.validate_token
    return false unless validate_token.success?

    response_body = JSON.parse(validate_token.body)
    response_body["data"]["uid"] == @uid
  end

  def to_h
    {
      "uid" => @uid,
      "client" => @client,
      "access-token" => @access_token
    }
  end

  def rdv_solidarites_client
    @rdv_solidarites_client ||= RdvSolidaritesClient.new(auth_headers: to_h)
  end
end
