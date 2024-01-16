describe RdvSolidaritesCredentialsFactory do
  describe ".create_with" do
    context "when not inclusion connected" do
      let!(:uid) { "someuid@gmail.com" }
      let!(:client) { "abvd" }
      let!(:access_token) { "agvj" }
      let!(:credentials) do
        { uid:, client:, access_token: }
      end

      let!(:rdv_solidarites_credentials) { instance_double(RdvSolidaritesCredentials::WithAccessToken) }

      before do
        allow(RdvSolidaritesCredentials::WithAccessToken).to receive(:new)
          .with(uid:, client:, access_token:).and_return(rdv_solidarites_credentials)
      end

      it "returns a session with access token" do
        expect(described_class.create_with(uid:, client:, access_token:)).to eq(rdv_solidarites_credentials)
      end
    end

    context "when inclusion connected" do
      let!(:uid) { "someuid@gmail.com" }
      let!(:x_agent_auth_signature) { "aazda" }
      let!(:rdv_solidarites_credentials) { instance_double(RdvSolidaritesCredentials::WithSharedSecret) }

      before do
        allow(RdvSolidaritesCredentials::WithSharedSecret).to receive(:new)
          .with(uid:, x_agent_auth_signature:).and_return(rdv_solidarites_credentials)
      end

      it "returns a session with access token" do
        expect(described_class.create_with(uid:, x_agent_auth_signature:, inclusion_connected: true))
          .to eq(rdv_solidarites_credentials)
      end
    end
  end
end
