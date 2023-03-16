describe InclusionConnectController do
  let(:base_url) { "https://test.inclusion.connect.fr" }
  let!(:agent) { create(:agent, last_name: "Leponge", first_name: "Bob", email: "bob@gmail.com") }
  let(:payload) do
    {
      id: agent.rdv_solidarites_agent_id,
      first_name: agent.first_name,
      last_name: agent.last_name,
      email: agent.email
    }
  end

  before do
    ENV["SHARED_SECRET_FOR_AGENTS_AUTH"] = "S3cr3T"
    stub_const("InclusionConnect::CLIENT_ID", "truc")
    stub_const("InclusionConnect::CLIENT_SECRET", "truc secret")
    stub_const("InclusionConnect::BASE_URL", base_url)
  end

  describe "#callback" do
    let(:code) { "1234" }

    it "redirect and returns an error if state doesn't match" do
      session[:ic_state] = "AZEERT"
      get :callback, params: { state: "zefjzelkf", code: code }
      expect(response).to redirect_to(sign_in_path)
      expect_flash_error
    end

    it "redirect and returns an error if token request error" do
      stub_token_request.to_return(status: 500, body: { error: "an error occurs" }.to_json, headers: {})

      session[:ic_state] = "a state"
      get :callback, params: { state: "a state", code: code }
      expect(response).to redirect_to(sign_in_path)
      expect_flash_error
    end

    it "redirect and returns an error if token request doesn't contains token" do
      stub_token_request.to_return(status: 200, body: {}.to_json, headers: {})

      session[:ic_state] = "a state"
      get :callback, params: { state: "a state", code: code }
      expect(response).to redirect_to(sign_in_path)
      expect_flash_error
    end

    it "redirect and returns an error if userinfo request doesnt work" do
      stub_token_request.to_return(
        status: 200, body: { access_token: "valid_token", scopes: "openid" }.to_json, headers: {}
      )
      stub_agent_info_request.to_return(
        status: 500, body: {}.to_json, headers: {}
      )
      session[:ic_state] = "a state"
      get :callback, params: { state: "a state", code: code }
      expect(response).to redirect_to(sign_in_path)
      expect_flash_error
    end

    it "redirect and returns an error if email_verified is false" do
      stub_token_request.to_return(
        status: 200, body: { access_token: "valid_token", scopes: "openid" }.to_json, headers: {}
      )
      stub_agent_info_request.to_return(
        status: 200, body: {
          email_verified: false,
          given_name: "Bob",
          family_name: "Leponge",
          email: "bob@gmail.com"
        }.to_json, headers: {}
      )
      session[:ic_state] = "a state"
      get :callback, params: { state: "a state", code: code }
      expect(response).to redirect_to(sign_in_path)
      expect_flash_error
    end

    it "redirect and returns an error if email is not the same as the agent" do
      stub_token_request.to_return(
        status: 200, body: { access_token: "valid_token", scopes: "openid" }.to_json, headers: {}
      )
      stub_agent_info_request.to_return(
        status: 200, body: {
          email_verified: false,
          given_name: "Bob",
          family_name: "Leponge",
          email: "pas_bob@gmail.com"
        }.to_json, headers: {}
      )
      session[:ic_state] = "a state"
      get :callback, params: { state: "a state", code: code }
      expect(response).to redirect_to(sign_in_path)
      expect_flash_error
    end

    it "redirect and assign session variables if everything is ok" do
      stub_token_request.to_return(
        status: 200, body: { access_token: "valid_token", scopes: "openid" }.to_json, headers: {}
      )
      stub_agent_info_request.to_return(
        status: 200, body: {
          email_verified: true,
          given_name: "Bob",
          family_name: "Leponge",
          email: "bob@gmail.com"
        }.to_json, headers: {}
      )
      session[:ic_state] = "a state"
      get :callback, params: { state: "a state", code: code }
      expect(response).to redirect_to(root_path)
      expect(request.session[:agent_id]).to eq(agent.id)
      expect(request.session[:rdv_solidarites]).to eq(
        {
          uid: agent.email,
          x_agent_auth_signature: OpenSSL::HMAC.hexdigest("SHA256", "S3cr3T", payload.to_json),
          inclusion_connected: true
        }
      )
    end

    it "call sentry about authentification failure" do
      stub_token_request.to_return(
        status: 200, body: { access_token: "valid_token", scopes: "openid" }.to_json, headers: {}
      )
      stub_agent_info_request.to_return(
        status: 200, body: {
          email_verified: true,
          given_name: "Autre",
          family_name: "Utilisateur",
          email: "pas_rdv_insertion@gmail.com"
        }.to_json, headers: {}
      )
      session[:ic_state] = "a state"
      expect(Sentry).to receive(:capture_message).with("Failed to authenticate agent with InclusionConnect")
      get :callback, params: { state: "a state", code: code }
    end
  end

  def expect_flash_error
    expect(flash[:error]).to eq(
      "Nous n'avons pas pu vous authentifier. Contacter le support à l'adresse" \
      "<data.insertion@beta.gouv.fr> si le problème persiste."
    )
  end
end
