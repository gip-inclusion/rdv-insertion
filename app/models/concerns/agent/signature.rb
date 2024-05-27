module Agent::Signature
  def sign_with(timestamp)
    payload = { id:, email:, timestamp: }
    OpenSSL::HMAC.hexdigest("SHA256", ENV.fetch("AGENT_SIGNATURE_KEY"), payload.to_json)
  end

  def signature_valid?(signature, timestamp)
    ActiveSupport::SecurityUtils.secure_compare(sign_with(timestamp), signature)
  end
end
