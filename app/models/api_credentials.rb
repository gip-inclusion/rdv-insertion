class ApiCredentials
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
    response = connection.get("/api/v1/auth/validate_token")
    response.success? && JSON.parse(response.body).dig("data", "uid") == @uid
  end

  def connection
    Faraday.new(
      url: ENV["RDV_SOLIDARITES_URL"],
      headers: {
        "uid" => @uid, "client" => @client, "access-token" => @access_token,
        "Content-Type" => "application/json"
      }
    )
  end
end
