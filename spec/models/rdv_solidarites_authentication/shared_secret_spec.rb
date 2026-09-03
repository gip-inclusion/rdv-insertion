describe RdvSolidaritesAuthentication::SharedSecret do
  subject { described_class.new(agent: agent) }

  let(:agent) do
    create(:agent, rdv_solidarites_agent_id: 42, first_name: "Jane", last_name: "Doe", email: "jane@gouv.fr")
  end

  describe "#headers" do
    it "signs the agent payload with the shared secret" do
      expected_signature = OpenSSL::HMAC.hexdigest(
        "SHA256",
        ENV.fetch("SHARED_SECRET_FOR_AGENTS_AUTH"),
        { id: 42, first_name: "Jane", last_name: "Doe", email: "jane@gouv.fr" }.to_json
      )

      expect(subject.headers).to eq(uid: "jane@gouv.fr", x_agent_auth_signature: expected_signature)
    end
  end

  describe "#renewable?" do
    it { expect(subject.renewable?).to be(false) }
  end
end
