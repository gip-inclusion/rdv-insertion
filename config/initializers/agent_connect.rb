unless Rails.env.test?
  AgentConnect.initialize! do |config|
    config.client_id = ENV["AGENT_CONNECT_CLIENT_ID"]
    config.client_secret = ENV["AGENT_CONNECT_CLIENT_SECRET"]
    config.scope = "openid email"
    config.base_url = ENV["AGENT_CONNECT_BASE_URL"]
    config.algorithm = "RS256"
  end
end
