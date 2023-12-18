module RdvSolidaritesClientSpecHelper
  def mock_rdv_solidarites_client(agent)
    allow(Current).to receive(:agent).and_return(agent)
    allow(RdvSolidaritesSession::WithSharedSecret).to receive(:new)
      .and_return(rdv_solidarites_session)
    allow(rdv_solidarites_session).to receive(:rdv_solidarites_client)
      .and_return(rdv_solidarites_client)
  end

  def shared_secret_session_hash(agent)
    { "uid" => agent.email, "x_agent_auth_signature" => agent.signature_auth_with_shared_secret }.symbolize_keys
  end

  def rdv_solidarites_session
    @rdv_solidarites_session ||= instance_double(RdvSolidaritesSession::WithSharedSecret)
  end
end
