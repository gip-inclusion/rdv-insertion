describe AgentCredentialsFactory do
  describe ".create_with" do
    context "when not inclusion connected" do
      let!(:uid) { "someuid@gmail.com" }
      let!(:client) { "abvd" }
      let!(:access_token) { "agvj" }
      let!(:credentials) do
        { uid:, client:, access_token: }
      end

      let!(:agent_credentials) { instance_double(AgentCredentials::WithAccessToken) }

      before do
        allow(AgentCredentials::WithAccessToken).to receive(:new)
          .with(uid:, client:, access_token:).and_return(agent_credentials)
      end

      it "returns a session with access token" do
        expect(described_class.create_with(uid:, client:, access_token:)).to eq(agent_credentials)
      end
    end

    context "when inclusion connected" do
      let!(:uid) { "someuid@gmail.com" }
      let!(:x_agent_auth_signature) { "aazda" }
      let!(:agent_credentials) { instance_double(AgentCredentials::WithSharedSecret) }

      before do
        allow(AgentCredentials::WithSharedSecret).to receive(:new)
          .with(uid:, x_agent_auth_signature:).and_return(agent_credentials)
      end

      it "returns a session with access token" do
        expect(described_class.create_with(uid:, x_agent_auth_signature:, inclusion_connected: true))
          .to eq(agent_credentials)
      end
    end
  end
end
