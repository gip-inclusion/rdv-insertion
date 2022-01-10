class RdvSolidaritesSession
  attr_reader :uid, :client, :access_token

  def initialize(uid:, client:, access_token:)
    @uid = uid
    @client = client
    @access_token = access_token
  end

  def valid?
    all_attributes_present? && token_valid?
  end

  def rdv_solidarites_client
    @rdv_solidarites_client ||= RdvSolidaritesClient.new(rdv_solidarites_session: self)
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
