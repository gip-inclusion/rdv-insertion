describe InclusionConnectSession do
  let(:agent) { create(:agent) }
  let(:shared_secret) { "S3cr3T" }
  let(:payload) do
    {
      id: agent.id,
      first_name: agent.first_name,
      last_name: agent.last_name,
      email: agent.email
    }
  end

  describe "#valid?" do
    before do
      allow(ENV).to receive(:fetch).with("SHARED_SECRET_FOR_AGENTS_AUTH").and_return("S3cr3T")
    end

    context "when required attributes are present and signature is valid" do
      let(:x_agent_auth_signature) { OpenSSL::HMAC.hexdigest("SHA256", shared_secret, payload.to_json) }
      let(:session) do
        RdvSolidaritesSession.from(:inclusion_connect).with(
          uid: agent.email, x_agent_auth_signature: x_agent_auth_signature
        )
      end

      it "session is valid" do
        expect(session).to be_valid
      end
    end

    context "when uid is missing" do
      let(:x_agent_auth_signature) { OpenSSL::HMAC.hexdigest("SHA256", shared_secret, payload.to_json) }
      let(:session) do
        RdvSolidaritesSession.from(:inclusion_connect).with(
          uid: nil, x_agent_auth_signature: x_agent_auth_signature
        )
      end

      it "session is invalid" do
        expect(session).not_to be_valid
      end
    end

    context "when x_agent_auth_signature is missing" do
      let(:session) do
        RdvSolidaritesSession.from(:inclusion_connect).with(
          uid: agent.email, x_agent_auth_signature: nil
        )
      end

      it "session is invalid" do
        expect(session).not_to be_valid
      end
    end

    context "when x_agent_auth_signature is invalid" do
      let(:x_agent_auth_signature) { "invalid_signature" }
      let(:session) do
        RdvSolidaritesSession.from(:inclusion_connect).with(
          uid: agent.email, x_agent_auth_signature: x_agent_auth_signature
        )
      end

      it "session is invalid" do
        expect(session).not_to be_valid
      end
    end
  end

  describe "#to_h" do
    let(:x_agent_auth_signature) { OpenSSL::HMAC.hexdigest("SHA256", shared_secret, payload.to_json) }
    let(:session) do
      RdvSolidaritesSession.from(:inclusion_connect).with(
        uid: agent.email, x_agent_auth_signature: x_agent_auth_signature
      )
    end

    it "returns a hash with uid and x_agent_auth_signature" do
      expect(session.to_h).to eq(
        {
          "uid" => agent.email,
          "x_agent_auth_signature" => x_agent_auth_signature
        }
      )
    end
  end
end
