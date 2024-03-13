class RetrieveInclusionConnectAgentInfos < BaseService
  def initialize(code:, callback_url:)
    @code = code
    @callback_url = callback_url
  end

  def call
    request_token!
    request_agent_info!
    retrieve_agent!
    # TODO : when we will have update endoint on rdvsp : update agent from rdvi
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
    fail!("Inclusion Connect sub and email mismatch") if agent_mismatch?

    result.agent = found_by_sub || found_by_email
    result.agent.presence || fail!("Agent doesn't exist in rdv-insertion")
  end

  def found_by_email
    fail!("Inclusion connect info has a nil mail") if agent_info_body["email"].nil?

    return @found_by_email if defined?(@found_by_email)

    @found_by_email = Agent.find_by(email: agent_info_body["email"])

    unless @found_by_email
      # Les domaines francetravail.fr et pole-emploi.fr sont équivalents
      # Enlever cette condition après la dernière vague de migration le 12 avril
      # Les agents seront mis à jour dans rdvi depuis RDVSP quand ils se connecteront sur rdvsp,
      # si il reste des agents avec des emails pole-emploi.fr aprés le 12/04 il faudra les mettre à jour manuellement
      name, domain = agent_info_body["email"].split("@")
      if domain.in?(["francetravail.fr", "pole-emploi.fr"])
        acceptable_emails = ["#{name}@francetravail.fr", "#{name}@pole-emploi.fr"]
        @found_by_email = Agent.find_by(email: acceptable_emails)
      end
    end

    @found_by_email
  end

  def found_by_sub
    fail!("Inclusion connect info has a nil sub") if agent_info_body["sub"].nil?

    @found_by_sub ||= Agent.find_by(inclusion_connect_open_id_sub: agent_info_body["sub"])
  end

  def agent_mismatch?
    found_by_sub && found_by_email && found_by_sub != found_by_email
  end
end
