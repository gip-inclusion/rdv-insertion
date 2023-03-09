module InclusionConnect
  CLIENT_ID = ENV["INCLUSION_CONNECT_CLIENT_ID"]
  CLIENT_SECRET = ENV["INCLUSION_CONNECT_CLIENT_SECRET"]
  BASE_URL = ENV["INCLUSION_CONNECT_BASE_URL"]

  class << self
    def auth_path(ic_state, inclusion_connect_callback_url)
      query = {
        response_type: "code",
        client_id: CLIENT_ID,
        redirect_uri: inclusion_connect_callback_url,
        scope: "openid email",
        state: ic_state,
        nonce: Digest::SHA1.hexdigest("Something to check when it come back ?"),
        from: "community"
      }
      "#{BASE_URL}/auth?#{query.to_query}"
    end

    def agent(code, inclusion_connect_callback_url)
      token = get_token(code, inclusion_connect_callback_url)
      return false if token.blank?

      user_info = get_user_info(token)
      return false if user_info.blank? || !user_info["email_verified"]

      Agent.find_by(email: user_info["email"])
    end

    private

    def get_token(code, inclusion_connect_callback_url)
      data = {
        client_id: CLIENT_ID,
        client_secret: CLIENT_SECRET,
        code: code,
        grant_type: "authorization_code",
        redirect_uri: inclusion_connect_callback_url,
      }
      uri = URI("#{BASE_URL}/token")

      response = Net::HTTP.post_form(uri, data)
      # check nonce here ?

      return false unless response.is_a?(Net::HTTPSuccess)

      JSON.parse(response.body)["access_token"]
    end

    def get_user_info(token)
      uri = URI("#{BASE_URL}/userinfo")
      uri.query = URI.encode_www_form({ schema: "openid" })
      req = Net::HTTP::Get.new(uri)
      req["Authorization"] = "Bearer #{token}"

      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
        http.request(req)
      end

      return false unless response.is_a?(Net::HTTPSuccess)

      JSON.parse(response.body)
    end
  end
end
