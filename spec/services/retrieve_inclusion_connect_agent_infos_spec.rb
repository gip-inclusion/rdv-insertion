describe RetrieveInclusionConnectAgentInfos, type: :service do
  subject do
    described_class.call(code: code, callback_url: callback_url)
  end

  let(:code) { "test_code" }
  let(:callback_url) { "https://example.com/callback" }
  let(:token_response) { instance_double("Faraday::Response", success?: true, body: token_body) }
  let(:token_body) { { "id_token" => "test_id_token", "access_token" => "test_access_token" }.to_json }
  let(:agent_info_response) { instance_double("Faraday::Response", success?: true, body: agent_info_body) }
  let(:agent_info_body) do
    {
      "email" => "test@example.com",
      "sub" => "test_sub"
    }.to_json
  end
  let!(:agent) { create(:agent, email: "test@example.com") }

  before do
    allow(InclusionConnectClient).to receive(:get_token).with(code, callback_url).and_return(token_response)
    allow(InclusionConnectClient).to receive(:get_agent_info).with(
      JSON.parse(token_body)["access_token"]
    ).and_return(agent_info_response)
  end

  describe "#call" do
    context "when the agent is found with email" do
      it "retrieves agent information and returns a successful result" do
        expect(subject).to be_success
        expect(subject.agent).to eq(agent)
        expect(subject.inclusion_connect_token_id).to eq(JSON.parse(token_body)["id_token"])
      end
    end

    context "when the token request fails" do
      let(:token_response) { instance_double("Faraday::Response", success?: false) }

      it "returns a failed result with an error message" do
        expect(subject).to be_failure
        expect(subject.errors).to include("Inclusion Connect API Error : Failed to retrieve token")
      end
    end

    context "when the agent info request fails" do
      let(:agent_info_response) { instance_double("Faraday::Response", success?: false) }

      it "returns a failed result with an error message" do
        expect(subject).to be_failure
        expect(subject.errors).to include("Inclusion Connect API Error : Failed to retrieve user informations")
      end
    end

    context "when the agent is not found" do
      let(:agent) { nil }

      it "returns a failed result with an error message" do
        expect(subject).to be_failure
        expect(subject.errors).to include("Agent doesn't exist in rdv-insertion")
      end
    end

    context "when the agent is found with a sub" do
      let(:agent_info_body) do
        {
          "email" => "test@example.com",
          "sub" => "test_sub"
        }.to_json
      end
      let!(:agent) { create(:agent, email: "old_email@example.com", inclusion_connect_open_id_sub: "test_sub") }

      it "retrieves agent information and returns a successful result based on sub" do
        expect(subject).to be_success
        expect(subject.agent).to eq(agent)
        expect(subject.inclusion_connect_token_id).to eq(JSON.parse(token_body)["id_token"])
      end
    end

    context "when the agent is found with a sub and email" do
      let(:agent_info_body) do
        {
          "email" => "agent_with_email@example.com",
          "sub" => "test_sub"
        }.to_json
      end
      let!(:agent_with_sub) { create(:agent, inclusion_connect_open_id_sub: "test_sub") }
      let!(:agent_with_email) { create(:agent, email: "agent_with_email@example.com") }

      it "fail and add error" do
        expect(subject).to be_failure
        expect(subject.errors).to include("Inclusion Connect sub and email mismatch")
      end
    end

    context "when inclusion connect send a nil email" do
      let(:agent_info_body) do
        {
          "email" => nil,
          "sub" => "test_sub"
        }.to_json
      end

      it "fail and add error" do
        expect(subject).to be_failure
        expect(subject.errors).to include("Inclusion connect info has a nil mail")
      end
    end

    context "when inclusion connect send a nil sub" do
      let(:agent_info_body) do
        {
          "email" => "test@example.fr",
          "sub" => nil
        }.to_json
      end

      it "fail and add error" do
        expect(subject).to be_failure
        expect(subject.errors).to include("Inclusion connect info has a nil sub")
      end
    end

    # --------------------------------------------------------------------------------------------
    # Remove this after france-travail migration is done 12 avril 2024
    # --------------------------------------------------------------------------------------------

    context "with a francetravail.fr domain" do
      let(:agent_info_body) do
        {
          "given_name" => "Bob",
          "family_name" => "Eponge",
          "email" => "bob@francetravail.fr",
          "sub" => "12345678-90ab-cdef-1234-567890abcdef"
        }.to_json
      end

      it "search @francetravail.fr (normal behavior)" do
        agent = create(:agent, email: "bob@francetravail.fr")
        expect(subject).to be_success
        expect(subject.agent).to have_attributes(
          id: agent.id,
          email: "bob@francetravail.fr"
        )
      end

      it "search @pole-emploi.fr" do
        agent = create(:agent, email: "bob@pole-emploi.fr")
        expect(subject).to be_success
        expect(subject.agent).to have_attributes(
          id: agent.id,
          email: "bob@pole-emploi.fr"
        )
      end
    end

    context "with a pole-emploi.fr domain" do
      let(:agent_info_body) do
        {
          "given_name" => "Bob",
          "family_name" => "Eponge",
          "email" => "bob@pole-emploi.fr",
          "sub" => "12345678-90ab-cdef-1234-567890abcdef"
        }.to_json
      end

      it "search @pole-emploi.fr (normal behavior)" do
        agent = create(:agent, email: "bob@pole-emploi.fr")
        expect(subject).to be_success
        expect(subject.agent).to have_attributes(
          id: agent.id,
          email: "bob@pole-emploi.fr"
        )
      end

      it "search @francetravail.fr" do
        agent = create(:agent, email: "bob@francetravail.fr")
        expect(agent.reload).to have_attributes(
          id: agent.id,
          email: "bob@francetravail.fr"
        )
      end
    end
  end
end
