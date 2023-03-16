describe RdvSolidaritesSessionFactory do
  describe ".create_with" do
    context "when not inclusion connected" do
      let!(:uid) { "someuid@gmail.com" }
      let!(:client) { "abvd" }
      let!(:access_token) { "agvj" }
      let!(:credentials) do
        { uid:, client:, access_token: }
      end

      let!(:rdv_solidarites_session) { instance_double(RdvSolidaritesSession::WithAccessToken) }

      before do
        allow(RdvSolidaritesSession::WithAccessToken).to receive(:new)
          .with(uid:, client:, access_token:).and_return(rdv_solidarites_session)
      end

      it "returns a session with access token" do
        expect(described_class.create_with(uid:, client:, access_token:)).to eq(rdv_solidarites_session)
      end
    end

    context "when inclusion connected" do
      let!(:uid) { "someuid@gmail.com" }
      let!(:x_agent_auth_signature) { "aazda" }
      let!(:rdv_solidarites_session) { instance_double(RdvSolidaritesSession::WithSharedSecret) }

      before do
        allow(RdvSolidaritesSession::WithSharedSecret).to receive(:new)
          .with(uid:, x_agent_auth_signature:).and_return(rdv_solidarites_session)
      end

      it "returns a session with access token" do
        expect(described_class.create_with(uid:, x_agent_auth_signature:, inclusion_connected: true))
          .to eq(rdv_solidarites_session)
      end
    end
  end
end
