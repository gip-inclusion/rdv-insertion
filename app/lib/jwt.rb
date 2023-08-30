module Jwt
  def generate_jwt(payload:, secret:, exp: 10.minutes.from_now.to_i)
    JWT.encode(payload, secret, "HS256", { typ: "JWT", exp: })
  end
end
