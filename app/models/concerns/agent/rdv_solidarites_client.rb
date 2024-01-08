module Agent::RdvSolidaritesClient
  def rdv_solidarites_client
    RdvSolidaritesClient.new(rdv_solidarites_credentials:)
  end

  def rdv_solidarites_credentials
    { uid: email, x_agent_auth_signature: signature_auth_with_shared_secret }
  end

  def signature_auth_with_shared_secret
    payload = {
      id: rdv_solidarites_agent_id,
      first_name: first_name,
      last_name: last_name,
      email: email
    }
    OpenSSL::HMAC.hexdigest("SHA256", ENV.fetch("SHARED_SECRET_FOR_AGENTS_AUTH"), payload.to_json)
  end
end
