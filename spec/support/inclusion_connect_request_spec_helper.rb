module InclusionConnectRequestSpecHelper
  def stub_token_request
    stub_request(:post, "#{base_url}/token")
  end

  def stub_agent_info_request
    stub_request(:get, "#{base_url}/userinfo").with(query: { schema: "openid" })
  end

  def stub_inclusion_connect_logout
    stub_request(:get, "#{base_url}/logout")
  end
end
