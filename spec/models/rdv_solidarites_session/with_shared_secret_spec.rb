describe RdvSolidaritesSession::WithSharedSecret do
  subject do
    described_class.new(
      uid: uid, x_agent_auth_signature: x_agent_auth_signature
    )
  end

  let!(:x_agent_auth_signature) { OpenSSL::HMAC.hexdigest("SHA256", shared_secret, payload.to_json) }
  let!(:uid) { agent.email }
  let!(:agent) { create(:agent) }
  let!(:shared_secret) { "S3cr3T" }
  let!(:payload) do
    {
      id: agent.rdv_solidarites_agent_id,
      first_name: agent.first_name,
      last_name: agent.last_name,
      email: agent.email
    }
  end

  describe "#valid?" do
    before { allow(Current).to receive(:agent).and_return(agent) }

    context "when required attributes are present and signature is valid" do
      it "session is valid" do
        expect(subject).to be_valid
      end
    end

    context "when uid is missing" do
      let!(:uid) { nil }

      it "session is invalid" do
        expect(subject).not_to be_valid
      end
    end

    context "when x_agent_auth_signature is missing" do
      let!(:x_agent_auth_signature) { nil }

      it "session is invalid" do
        expect(subject).not_to be_valid
      end
    end

    context "when x_agent_auth_signature is invalid" do
      let(:x_agent_auth_signature) { "invalid_signature" }

      it "session is invalid" do
        expect(subject).not_to be_valid
      end
    end
  end

  describe "#credentials" do
    it "returns a hash with uid and x_agent_auth_signature" do
      expect(subject.credentials).to eq(
        {
          "uid" => uid,
          "x_agent_auth_signature" => x_agent_auth_signature
        }
      )
    end
  end
end
