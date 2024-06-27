class InclusionConnectClient
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
        from: "community"
      }
      "#{BASE_URL}/authorize/?#{query.to_query}"
    end

    def get_token(code, inclusion_connect_callback_url)
      data = {
        client_id: CLIENT_ID,
        client_secret: CLIENT_SECRET,
        code: code,
        grant_type: "authorization_code",
        redirect_uri: inclusion_connect_callback_url
      }
      Faraday.post(
        URI("#{BASE_URL}/token/"),
        data
      )
    end

    def logout_path(id_token, ic_state)
      query = {
        id_token_hint: id_token,
        state: ic_state,
        post_logout_redirect_uri: "#{ENV['HOST']}/sign_in"
      }
      "#{BASE_URL}/logout?#{query.to_query}"
    end

    def get_agent_info(access_token)
      data = { schema: "openid" }
      request_headers = { "Authorization" => "Bearer #{access_token}" }

      Faraday.get(
        "#{BASE_URL}/userinfo/",
        data,
        request_headers
      )
    end
  end
end
