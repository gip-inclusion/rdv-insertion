describe RdvSolidaritesApi::CreateUserProfiles, type: :service do
  subject do
    described_class.call(
      rdv_solidarites_user_id: rdv_solidarites_user_id,
      rdv_solidarites_organisation_ids: rdv_solidarites_organisation_ids
    )
  end

  let!(:agent) { create(:agent) }
  let!(:rdv_solidarites_user_id) { 33 }
  let!(:rdv_solidarites_organisation_ids) { [44, 55] }
  let!(:rdv_solidarites_session_with_shared_secret) { instance_double(RdvSolidaritesSession::WithSharedSecret) }
  let!(:rdv_solidarites_client) { instance_double(RdvSolidaritesClient) }

  describe "#call" do
    let(:response_body) do
      { referent_assignations: { rdv_solidarites_user_id: rdv_solidarites_user_id,
                                 rdv_solidarites_organisation_ids: rdv_solidarites_organisation_ids } }.to_json
    end

    before do
      allow(Current).to receive(:agent).and_return(agent)
      allow(RdvSolidaritesSession::WithSharedSecret).to receive(:new)
        .and_return(rdv_solidarites_session_with_shared_secret)
      allow(rdv_solidarites_session_with_shared_secret).to receive(:rdv_solidarites_client)
        .and_return(rdv_solidarites_client)
      allow(rdv_solidarites_client).to receive(:create_user_profiles)
        .with(rdv_solidarites_user_id, rdv_solidarites_organisation_ids)
        .and_return(OpenStruct.new(success?: true, body: response_body))
    end

    it "tries to assign user to multiple organisations in rdv solidarites" do
      expect(rdv_solidarites_client).to receive(:create_user_profiles)
        .with(rdv_solidarites_user_id, rdv_solidarites_organisation_ids)
      subject
    end

    it "is a success" do
      is_a_success
    end

    context "when the response is unsuccessful" do
      let(:response_body) { { error_messages: ["some error"] }.to_json }

      before do
        allow(rdv_solidarites_client).to receive(:create_user_profiles)
          .with(rdv_solidarites_user_id, rdv_solidarites_organisation_ids)
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
