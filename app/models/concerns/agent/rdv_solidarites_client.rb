module Agent::RdvSolidaritesClient
  def rdv_solidarites_client
    RdvSolidaritesClient.new(auth_headers: rdv_solidarites_auth_headers_with_shared_secret)
  end

  def with_rdv_solidarites_client(&)
    # This ensure Current.rdv_solidarites_client would call the agent rdv_solidarites_client
    Current.agent = self
    yield
  ensure
    Current.agent = nil
  end

  private

  def rdv_solidarites_auth_headers_with_shared_secret
    { uid: email, x_agent_auth_signature: rdv_solidarites_signature }
  end

  def rdv_solidarites_signature
    payload = {
      id: rdv_solidarites_agent_id,
      first_name: first_name,
      last_name: last_name,
      email: email
    }
    OpenSSL::HMAC.hexdigest("SHA256", ENV.fetch("SHARED_SECRET_FOR_AGENTS_AUTH"), payload.to_json)
  end
end
