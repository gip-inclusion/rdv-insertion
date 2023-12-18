describe RdvSolidaritesApi::CreateReferentAssignation, type: :service do
  subject do
    described_class.call(rdv_solidarites_user_id:, rdv_solidarites_agent_id:)
  end

  let!(:agent) { create(:agent) }
  let!(:rdv_solidarites_client) { instance_double(RdvSolidaritesClient) }
  let!(:rdv_solidarites_user_id) { 33 }
  let!(:rdv_solidarites_agent_id) { 44 }

  describe "#call" do
    let(:response_body) do
      { referent_assignations: { rdv_solidarites_user_id: rdv_solidarites_user_id,
                                 rdv_solidarites_agent_id: rdv_solidarites_agent_id } }.to_json
    end

    before do
      mock_rdv_solidarites_client(agent)
      allow(rdv_solidarites_client).to receive(:create_referent_assignation)
        .with(rdv_solidarites_user_id, rdv_solidarites_agent_id)
        .and_return(OpenStruct.new(success?: true, body: response_body))
    end

    it "tries to creates a referent assignation in rdv solidarites" do
      expect(rdv_solidarites_client).to receive(:create_referent_assignation)
        .with(rdv_solidarites_user_id, rdv_solidarites_agent_id)
      subject
    end

    it "is a success" do
      is_a_success
    end

    context "when the response is unsuccessful" do
      let(:response_body) { { error_messages: ["some error"] }.to_json }

      before do
        allow(rdv_solidarites_client).to receive(:create_referent_assignation)
          .with(rdv_solidarites_user_id, rdv_solidarites_agent_id)
          .and_return(OpenStruct.new(body: response_body, success?: false))
      end

      it "is a failure" do
        is_a_failure
      end

      it "stores the error" do
        expect(subject.errors).to eq(["Erreur RDV-Solidarités: some error"])
      end
    end
  end
end
