module Agent::RdvSolidaritesClient
  def rdv_solidarites_client
    @rdv_solidarites_client ||= RdvSolidaritesClient.new(
      authentication: RdvSolidaritesAuthentication::Oauth.new(agent: self)
    )
  end
end
