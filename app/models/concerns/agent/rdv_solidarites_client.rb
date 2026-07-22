module Agent::RdvSolidaritesClient
  def rdv_solidarites_client
    @rdv_solidarites_client ||= RdvSolidaritesClient.new(authentication: rdv_solidarites_authentication)
  end

  private

  def rdv_solidarites_authentication
    if rdv_solidarites_oauth_token
      RdvSolidaritesAuthentication::Oauth.new(agent: self)
    else
      RdvSolidaritesAuthentication::SharedSecret.new(agent: self)
    end
  end
end
