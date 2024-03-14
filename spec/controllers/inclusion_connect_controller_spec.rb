describe InclusionConnectController do
  let(:base_url) { "https://test.inclusion.connect.fr" }
  let!(:agent) do
    create(
      :agent,
      last_name: "Leponge",
      first_name: "Bob",
      email: "bob@gmail.com"
    )
  end
  let!(:agent_with_sub) { create(:agent, inclusion_connect_open_id_sub: "agent_with_sub") }
  let(:payload) do
    {
      id: agent.rdv_solidarites_agent_id,
      first_name: agent.first_name,
      last_name: agent.last_name,
      email: agent.email
    }
  end

  before do
    stub_const("InclusionConnectClient::CLIENT_ID", "truc")
    stub_const("InclusionConnectClient::CLIENT_SECRET", "truc secret")
    stub_const("InclusionConnectClient::BASE_URL", base_url)
  end

  describe "#callback" do
    let(:code) { "1234" }

    before do
      session[:ic_state] = "a state"
    end

    it "redirect and returns an error if state doesn't match" do
      session[:ic_state] = "AZEERT"
      expect(Sentry).to receive(:capture_message).with(
        "Failed to authenticate agent with InclusionConnect : Invalid State"
      )
      get :callback, params: { state: "zefjzelkf", code: code }
      expect(response).to redirect_to(sign_in_path)
      expect_flash_error
    end

    it "redirect and returns an error if token request failed" do
      stub_token_request.to_return(status: 500, body: { error: "an error occurs" }.to_json, headers: {})
      expect(Sentry).to receive(:capture_message).with("Inclusion Connect API Error : Failed to retrieve token")
      get :callback, params: { state: "a state", code: code }
      expect(response).to redirect_to(sign_in_path)
      expect_flash_error
    end

    it "redirect and returns an error if userinfo request failed" do
      stub_token_request.to_return(
        status: 200, body: { access_token: "valid_token", scopes: "openid" }.to_json, headers: {}
      )
      stub_agent_info_request.to_return(
        status: 500, body: {}.to_json, headers: {}
      )
      expect(Sentry).to receive(:capture_message).with(
        "Inclusion Connect API Error : Failed to retrieve user informations"
      )
      get :callback, params: { state: "a state", code: code }
      expect(response).to redirect_to(sign_in_path)
      expect_flash_error
    end

    it "redirect and returns an error if agent email doesnt exist in rdv-i" do
      stub_token_request.to_return(
        status: 200, body: { access_token: "valid_token", scopes: "openid" }.to_json, headers: {}
      )
      stub_agent_info_request.to_return(
        status: 200, body: {
          given_name: "Patrick",
          family_name: "Letoile",
          email: "patrick@gmail.com",
          sub: "patrick"
        }.to_json, headers: {}
      )
      expect(Sentry).to receive(:capture_message).with("Agent doesn't exist in rdv-insertion")
      get :callback, params: { state: "a state", code: code }
      expect(response).to redirect_to(sign_in_path)
      expect_flash_error
    end

    it "redirect and returns an error if agent mismatch with email and sub" do
      stub_token_request.to_return(
        status: 200, body: { access_token: "valid_token", scopes: "openid" }.to_json, headers: {}
      )
      stub_agent_info_request.to_return(
        status: 200, body: {
          given_name: "Bob",
          family_name: "Leponge",
          email: "bob@gmail.com",
          sub: "agent_with_sub"
        }.to_json, headers: {}
      )
      expect(Sentry).to receive(:capture_message).with("Inclusion Connect sub and email mismatch")
      get :callback, params: { state: "a state", code: code }
      expect(response).to redirect_to(sign_in_path)
      expect_flash_error
    end

    it "redirect and assign session variables if everything is ok (with stub request)" do
      allow(RetrieveInclusionConnectAgentInfos).to receive(:call).with(
        code: code,
        callback_url: inclusion_connect_callback_url
      ).and_return(
        OpenStruct.new(success?: true, agent: agent, inclusion_connect_token_id: "123", errors: [])
      )
      stub_token_request.to_return(
        status: 200, body: { access_token: "valid_token", scopes: "openid", id_token: "123" }.to_json, headers: {}
      )
      stub_agent_info_request.to_return(
        status: 200, body: {
          given_name: "Bob",
          family_name: "Leponge",
          email: "bob@gmail.com",
          sub: "Bob"
        }.to_json, headers: {}
      )
      get :callback, params: { state: "a state", code: code }
      expect(response).to redirect_to(root_path)
      expect(request.session[:inclusion_connect_token_id]).to eq("123")
      expect(request.session[:agent_id]).to eq(agent.id)
      expect(request.session[:rdv_solidarites_credentials]).to eq(
        {
          uid: agent.email,
          x_agent_auth_signature: OpenSSL::HMAC.hexdigest("SHA256", "S3cr3T", payload.to_json),
          inclusion_connected: true
        }
      )
    end

    it "redirect and assign session variables if everything is ok (with stub service)" do
      allow(RetrieveInclusionConnectAgentInfos).to receive(:call).with(
        code: code,
        callback_url: inclusion_connect_callback_url
      ).and_return(
        OpenStruct.new(success?: true, agent: agent, inclusion_connect_token_id: "123", errors: [])
      )
      get :callback, params: { state: "a state", code: code }
      expect(response).to redirect_to(root_path)
      expect(request.session[:inclusion_connect_token_id]).to eq("123")
      expect(request.session[:agent_id]).to eq(agent.id)
      expect(request.session[:rdv_solidarites_credentials]).to eq(
        {
          uid: agent.email,
          x_agent_auth_signature: OpenSSL::HMAC.hexdigest("SHA256", "S3cr3T", payload.to_json),
          inclusion_connected: true
        }
      )
    end
  end

  def expect_flash_error
    expect(flash[:error]).to eq(
      "Nous n'avons pas pu vous authentifier. Contacter le support à l'adresse" \
      "<rdv-insertion@beta.gouv.fr> si le problème persiste."
    )
  end

  def stub_token_request
    stub_request(:post, "#{base_url}/token/")
  end

  def stub_agent_info_request
    stub_request(:get, "#{base_url}/userinfo/").with(query: { schema: "openid" })
  end
end
