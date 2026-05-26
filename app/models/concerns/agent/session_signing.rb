module Agent::SessionSigning
  def sign_with(timestamp)
    payload = { id:, email:, timestamp: }
    OpenSSL::HMAC.hexdigest("SHA256", signature_key, payload.to_json)
  end

  def signature_valid?(signature, timestamp)
    ActiveSupport::SecurityUtils.secure_compare(sign_with(timestamp), signature)
  end

  private

  def signature_key
    ENV.fetch("AGENT_SIGNATURE_KEY")
  end
end
