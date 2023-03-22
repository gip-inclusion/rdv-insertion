describe InclusionConnectClient do
  let(:base_url) { "https://test.inclusion.connect.fr" }

  before do
    stub_const("InclusionConnectClient::CLIENT_ID", "truc")
    stub_const("InclusionConnectClient::CLIENT_SECRET", "truc secret")
    stub_const("InclusionConnectClient::BASE_URL", base_url)
  end

  describe "#auth_path" do
    let(:ic_state) { "1234" }
    let(:inclusion_connect_callback_url) { "http://localhost:3000/callback" }
    let(:auth_path) { subject.auth_path(ic_state, inclusion_connect_callback_url) }

    it "returns the correct auth path" do
      expect(auth_path).to eq(
        "#{base_url}/auth?client_id=truc&from=community&redirect_uri=" \
        "#{URI.encode_www_form_component(inclusion_connect_callback_url)}&response_type=" \
        "code&scope=openid+email&state=#{ic_state}"
      )
    end
  end

  describe "#find_agent" do
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
        expect(subject.find_agent(code, inclusion_connect_callback_url)).to eq(agent)
      end
    end

    context "When the token and agent info requests are valid but agent doesnt exist in db" do
      it "returns nil" do
        stub_token_request.to_return(
          status: 200, body: { access_token: "valid_token", scopes: "openid" }.to_json, headers: {}
        )
        stub_agent_info_request.to_return(
          status: 200, body: {
            email_verified: true,
            given_name: "Alain",
            family_name: "Leponge",
            email: "alain@gmail.com"
          }.to_json, headers: {}
        )
        expect(subject.find_agent(code, inclusion_connect_callback_url)).to be_nil
      end
    end

    context "when the token is blank" do
      it "returns false" do
        stub_token_request.to_return(
          status: 200, body: { access_token: nil, scopes: "openid" }.to_json, headers: {}
        )
        expect(subject.find_agent(code, inclusion_connect_callback_url)).to be_falsey
      end
    end

    context "when the token request fail" do
      it "returns false" do
        stub_token_request.to_return(
          status: 401, body: {}.to_json, headers: {}
        )
        expect(subject.find_agent(code, inclusion_connect_callback_url)).to be_falsey
      end
    end

    context "when the agent info request fail" do
      it "returns false" do
        stub_token_request.to_return(
          status: 200, body: { access_token: "valid_token", scopes: "openid" }.to_json, headers: {}
        )
        stub_agent_info_request.to_return(
          status: 401, body: {}.to_json, headers: {}
        )
        expect(subject.find_agent(code, inclusion_connect_callback_url)).to be_falsey
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
        expect(subject.find_agent(code, inclusion_connect_callback_url)).to be_falsey
      end
    end
  end
end
