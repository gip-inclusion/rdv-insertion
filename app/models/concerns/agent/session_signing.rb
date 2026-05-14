module Agent::SessionSigning
  class NotSignableError < StandardError; end

  def sign_with(timestamp)
    raise NotSignableError unless signable?

    payload = { id:, timestamp:, session_key: }
    OpenSSL::HMAC.hexdigest("SHA256", signature_key, payload.to_json)
  end

  def signature_valid?(signature, timestamp)
    signable? && ActiveSupport::SecurityUtils.secure_compare(sign_with(timestamp), signature)
  end

  private

  def signable?
    session_key.present? && signature_key.present?
  end

  def signature_key
    ENV["AGENT_SIGNATURE_KEY"]
  end
end
