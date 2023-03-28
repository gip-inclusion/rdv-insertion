describe Client::InclusionConnect do
  let(:base_url) { "https://test.inclusion.connect.fr" }

  before do
    stub_const("Client::InclusionConnect::CLIENT_ID", "truc")
    stub_const("Client::InclusionConnect::CLIENT_SECRET", "truc secret")
    stub_const("Client::InclusionConnect::BASE_URL", base_url)
  end

  describe "#auth_path" do
    let(:ic_state) { "1234" }
    let(:inclusion_connect_callback_url) { "http://localhost:3000/callback" }
    let(:auth_path) { described_class.auth_path(ic_state, inclusion_connect_callback_url) }

    it "returns the correct auth path" do
      expect(auth_path).to eq(
        "#{base_url}/auth?client_id=truc&from=community&redirect_uri=" \
        "#{URI.encode_www_form_component(inclusion_connect_callback_url)}&response_type=" \
        "code&scope=openid+email&state=#{ic_state}"
      )
    end
  end

  describe "#logout" do
    let(:token) { "valid_token" }

    context "when the logout request is successful" do
      it "returns true" do
        stub_inclusion_connect_logout
          .with(query: { id_token_hint: token })
          .to_return(status: 200, body: "", headers: {})

        expect(described_class.logout(token)).to be_truthy
      end
    end

    context "when the logout request fails" do
      it "returns false" do
        stub_request(:get, "#{base_url}/logout")
          .with(query: { id_token_hint: token })
          .to_return(status: 401, body: "", headers: {})

        expect(described_class.logout(token)).to be_falsey
      end
    end
  end

  describe "#connect" do
    let(:code) { "1234" }
    let(:inclusion_connect_callback_url) { "http://localhost:3000/callback" }

    context "when the connect request is successful" do
      let(:response_body) { { access_token: "valid_token", id_token: "valid_id_token" }.to_json }

      before do
        stub_token_request.to_return(status: 200, body: response_body, headers: {})
      end

      it "returns the parsed response body" do
        result = described_class.connect(code, inclusion_connect_callback_url)
        expect(result).to eq(JSON.parse(response_body))
      end
    end

    context "when the connect request fails" do
      before do
        stub_token_request.to_return(
          status: 401, body: {}.to_json, headers: {}
        )
      end

      it "returns an empty hash" do
        result = described_class.connect(code, inclusion_connect_callback_url)
        expect(result).to eq({})
      end
    end
  end

  describe "#retrieve_agent_email from IC API" do
    let(:code) { "1234" }
    let(:inclusion_connect_callback_url) { "http://localhost:3000/callback" }
    let!(:agent) { create(:agent, first_name: "Bob", last_name: "Leponge", email: "bob@gmail.com") }

    context "When the token and agent info requests are valid" do
      it "returns the agent" do
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
        expect(described_class.retrieve_agent_email("valid_token")).to eq(agent.email)
      end
    end

    context "when the token request fails" do
      it "returns false" do
        stub_token_request.to_return(
          status: 401, body: {}.to_json, headers: {}
        )
        stub_agent_info_request.to_return(
          status: 200, body: {}.to_json, headers: {}
        )
        expect(described_class.retrieve_agent_email("valid_token")).to be_falsey
      end
    end

    context "when the agent info request fails" do
      it "returns false" do
        stub_token_request.to_return(
          status: 200, body: { access_token: "valid_token", scopes: "openid" }.to_json, headers: {}
        )
        stub_agent_info_request.to_return(
          status: 401, body: {}.to_json, headers: {}
        )
        expect(described_class.retrieve_agent_email("valid_token")).to be_falsey
      end
    end

    context "when the email is not verified" do
      it "returns false" do
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
        expect(described_class.retrieve_agent_email("valid_token")).to be_falsey
      end
    end
  end
end
