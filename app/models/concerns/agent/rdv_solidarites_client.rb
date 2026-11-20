module Agent::RdvSolidaritesClient
  def rdv_solidarites_client
    @rdv_solidarites_client ||= RdvSolidaritesClient.new(agent: self)
  end
end
