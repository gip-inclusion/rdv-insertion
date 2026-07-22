class RdvSolidaritesOauthClient
  def initialize(api_token:, refresh_token:)
    @api_token = api_token
    @refresh_token = refresh_token
  end

  def refresh
    OAuth2::AccessToken.new(client, @api_token, refresh_token: @refresh_token).refresh!
  end

  private

  def client
    OAuth2::Client.new(
      ENV["RDV_SOLIDARITES_OAUTH_APP_ID"],
      ENV["RDV_SOLIDARITES_OAUTH_APP_SECRET"],
      site: ENV["RDV_SOLIDARITES_URL"]
    )
  end
end
