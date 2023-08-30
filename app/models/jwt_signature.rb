class JwtSignature
  include Jwt

  def initialize(payload:, secret:, exp: 10.minutes.from_now.to_i)
    @payload = payload
    @secret = secret
    @exp = exp
  end

  def to_h
    { "Authorization" => "Bearer #{jwt}" }
  end

  def jwt
    JWT.encode(@payload, @secret, "HS256", { typ: "JWT", exp: @exp })
  end
end
