describe RdvSolidaritesApi::CreateReferentAssignations, type: :service do
  subject do
    described_class.call(rdv_solidarites_user_id:, rdv_solidarites_agent_ids:)
  end

  let!(:rdv_solidarites_client) { instance_double(RdvSolidaritesClient) }
  let!(:rdv_solidarites_user_id) { 33 }
  let!(:rdv_solidarites_agent_ids) { [44, 55] }

  describe "#call" do
    let(:response_body) do
      { referent_assignations: { rdv_solidarites_user_id: rdv_solidarites_user_id,
                                 rdv_solidarites_agent_ids: rdv_solidarites_agent_ids } }.to_json
    end

    before do
      allow(Current).to receive(:rdv_solidarites_client).and_return(rdv_solidarites_client)
      allow(rdv_solidarites_client).to receive(:create_referent_assignations)
        .with(rdv_solidarites_user_id, rdv_solidarites_agent_ids)
        .and_return(OpenStruct.new(success?: true, body: response_body))
    end

    it "tries to creates multiple referent assignations in rdv solidarites" do
      expect(rdv_solidarites_client).to receive(:create_referent_assignations)
        .with(rdv_solidarites_user_id, rdv_solidarites_agent_ids)
      subject
    end

    it "is a success" do
      is_a_success
    end

    context "when the response is unsuccessful" do
      let(:response_body) { { error_messages: ["some error"] }.to_json }

      before do
        allow(rdv_solidarites_client).to receive(:create_referent_assignations)
          .with(rdv_solidarites_user_id, rdv_solidarites_agent_ids)
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
