module Agent::SessionSigning
  def sign_with(timestamp)
    payload = { id:, email:, timestamp: }
    OpenSSL::HMAC.hexdigest("SHA256", signature_key, payload.to_json)
  end

  def signature_valid?(signature, timestamp)
    signature_key.present? && ActiveSupport::SecurityUtils.secure_compare(sign_with(timestamp), signature)
  end

  private

  def signature_key
    ENV["AGENT_SIGNATURE_KEY"]
  end
end
