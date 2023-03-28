describe RetrieveInclusionConnectAgentInfos, type: :service do
  subject do
    described_class.call(code: code, callback_url: callback_url)
  end

  let(:code) { "test_code" }
  let(:callback_url) { "https://example.com/callback" }
  let(:connect_response) { instance_double("Faraday::Response", success?: true, body: connect_body) }
  let(:connect_body) { { "id_token" => "test_id_token", "access_token" => "test_access_token" }.to_json }
  let(:agent_info_response) { instance_double("Faraday::Response", success?: true, body: agent_info_body) }
  let(:agent_info_body) { { "email_verified" => true, "email" => "test@example.com" }.to_json }
  let!(:agent) { create(:agent, email: "test@example.com") }

  before do
    allow(Client::InclusionConnect).to receive(:connect).with(code, callback_url).and_return(connect_response)
    allow(Client::InclusionConnect).to receive(:get_agent_info).with(
      JSON.parse(connect_body)["access_token"]
    ).and_return(agent_info_response)
    allow(Agent).to receive(:find_by).with(email: JSON.parse(agent_info_body)["email"]).and_return(agent)
  end

  describe "#call" do
    context "when the agent is found and email is verified" do
      it "retrieves agent information and returns a successful result" do
        expect(subject).to be_success
        expect(subject.agent).to eq(agent)
        expect(subject.inclusion_connect_token_id).to eq(JSON.parse(connect_body)["id_token"])
      end
    end

    context "when the connect request fails" do
      let(:connect_response) { instance_double("Faraday::Response", success?: false) }

      it "returns a failed result with an error message" do
        expect(subject).to be_failure
        expect(subject.errors).to include("Inclusion Connect API Error : Connexion failed")
      end
    end

    context "when the agent info request fails" do
      let(:agent_info_response) { instance_double("Faraday::Response", success?: false) }

      it "returns a failed result with an error message" do
        expect(subject).to be_failure
        expect(subject.errors).to include("Inclusion Connect API Error : Failed to retrieve user informations")
      end
    end

    context "when the email is not verified" do
      let(:agent_info_body) { { "email_verified" => false, "email" => "test@example.com" }.to_json }

      it "returns a failed result with an error message" do
        expect(subject).to be_failure
        expect(subject.errors).to include("Inclusion Connect Error: Email not verified")
      end
    end

    context "when the agent is not found" do
      let(:agent) { nil }

      it "returns a failed result with an error message" do
        expect(subject).to be_failure
        expect(subject.errors).to include("Agent doesnt exist in rdv-insertion")
      end
    end
  end
end
