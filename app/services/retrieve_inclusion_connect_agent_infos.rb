class RetrieveInclusionConnectAgentInfos < BaseService
  def initialize(code:, callback_url:)
    @code = code
    @callback_url = callback_url
  end

  def call
    request_connect!
    request_agent_info!
    retrieve_agent!
    retrieve_token_id!
  end

  private

  def request_connect!
    return if connect_response.success?

    fail!("Inclusion Connect API Error : Connexion failed")
  end

  def connect_response
    @connect_response ||= Client::InclusionConnect.connect(@code, @callback_url)
  end

  def connect_body
    JSON.parse(connect_response.body)
  end

  def retrieve_token_id!
    result.inclusion_connect_token_id = connect_body["id_token"]
  end

  def request_agent_info!
    return if agent_info_response.success?

    fail!("Inclusion Connect API Error : Failed to retrieve user informations")
  end

  def agent_info_response
    @agent_info_response ||= Client::InclusionConnect.get_agent_info(connect_body["access_token"])
  end

  def agent_info_body
    JSON.parse(agent_info_response.body)
  end

  def retrieve_agent!
    fail!("Inclusion Connect Error: Email not verified") unless agent_info_body["email_verified"]
    result.agent = Agent.find_by(email: agent_info_body["email"])
    result.agent.presence || fail!("Agent doesnt exist in rdv-insertion")
  end
end
