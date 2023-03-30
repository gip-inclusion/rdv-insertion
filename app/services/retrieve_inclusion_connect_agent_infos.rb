class RetrieveInclusionConnectAgentInfos < BaseService
  def initialize(code:, callback_url:)
    @code = code
    @callback_url = callback_url
  end

  def call
    request_token!
    request_agent_info!
    check_email_verified!
    retrieve_agent!
    retrieve_token_id
  end

  private

  def request_token!
    return if token_response.success?

    fail!("Inclusion Connect API Error : Failed to retrieve token")
  end

  def token_response
    @token_response ||= InclusionConnectClient.get_token(@code, @callback_url)
  end

  def token_body
    JSON.parse(token_response.body)
  end

  def retrieve_token_id
    result.inclusion_connect_token_id = token_body["id_token"]
  end

  def request_agent_info!
    return if agent_info_response.success?

    fail!("Inclusion Connect API Error : Failed to retrieve user informations")
  end

  def agent_info_response
    @agent_info_response ||= InclusionConnectClient.get_agent_info(token_body["access_token"])
  end

  def agent_info_body
    JSON.parse(agent_info_response.body)
  end

  def retrieve_agent!
    result.agent = Agent.find_by(email: agent_info_body["email"])
    result.agent.presence || fail!("Agent doesn't exist in rdv-insertion")
  end

  def check_email_verified!
    return if agent_info_body["email_verified"]

    fail!("Inclusion Connect Error: Email not verified")
  end
end
