module InclusionConnectRequestSpecHelper
  def stub_token_request
    stub_request(:post, "#{base_url}/token").with(
      body: {
        "client_id" => "truc",
        "client_secret" => "truc secret",
        "code" => code,
        "grant_type" => "authorization_code",
        "redirect_uri" => inclusion_connect_callback_url
      },
      headers: {
        "Accept" => "*/*",
        "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
        "Content-Type" => "application/x-www-form-urlencoded",
        "User-Agent" => "Faraday v2.7.2"
      }
    )
  end

  def stub_agent_info_request
    stub_request(:get, "#{base_url}/userinfo?schema=openid").with(
      headers: {
        "Accept" => "*/*",
        "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
        "Authorization" => "Bearer valid_token",
        "User-Agent" => "Faraday v2.7.2"
      }
    )
  end
end
