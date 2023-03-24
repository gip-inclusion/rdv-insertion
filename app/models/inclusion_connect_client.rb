module InclusionConnectClient
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
      "#{BASE_URL}/auth?#{query.to_query}"
    end

    def connect(code, inclusion_connect_callback_url)
      data = {
        client_id: CLIENT_ID,
        client_secret: CLIENT_SECRET,
        code: code,
        grant_type: "authorization_code",
        redirect_uri: inclusion_connect_callback_url
      }

      response = Faraday.post(
        URI("#{BASE_URL}/token"),
        data
      )

      return false unless response.success?

      JSON.parse(response.body)
    end

    def logout(token)
      response = Faraday.get(
        "#{BASE_URL}/logout",
        {
          id_token_hint: token
        }
      )
      return false unless response.success?

      true
    end

    def retrieve_access_token(response)
      response["access_token"]
    end

    def retrieve_id_token(response)
      response["id_token"]
    end

    def retrieve_agent_email(token)
      agent_info = get_agent_info(token)
      return false unless agent_info.present? && agent_info["email_verified"]

      agent_info["email"]
    end

    private

    def get_agent_info(token)
      uri = URI("#{BASE_URL}/userinfo")
      uri.query = URI.encode_www_form({ schema: "openid" })

      request = Faraday.new(uri)
      request.headers["Authorization"] = "Bearer #{token}"
      response = request.get

      return false unless response.success?

      JSON.parse(response.body)
    end
  end
end
