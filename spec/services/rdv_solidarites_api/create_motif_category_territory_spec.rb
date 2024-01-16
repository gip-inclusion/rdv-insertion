describe RdvSolidaritesApi::CreateMotifCategoryTerritory, type: :service do
  subject do
    described_class.call(
      motif_category_short_name: motif_category_short_name,
      organisation_id: organisation_id
    )
  end

  let!(:agent) { create(:agent) }
  let!(:motif_category_short_name) { "rsa_orientation" }
  let!(:organisation_id) { 44 }
  let!(:rdv_solidarites_session_with_shared_secret) { instance_double(RdvSolidaritesSession::WithSharedSecret) }
  let!(:rdv_solidarites_client) { instance_double(RdvSolidaritesClient) }

  describe "#call" do
    before do
      allow(Current).to receive(:agent).and_return(agent)
      allow(RdvSolidaritesSession::WithSharedSecret).to receive(:new)
        .and_return(rdv_solidarites_session_with_shared_secret)
      allow(rdv_solidarites_session_with_shared_secret).to receive(:rdv_solidarites_client)
        .and_return(rdv_solidarites_client)
      allow(rdv_solidarites_client).to receive(:create_motif_category_territory)
        .and_return(OpenStruct.new(success?: true))
    end

    it "tries to create a motif category territory on rdvs" do
      expect(rdv_solidarites_client).to receive(:create_motif_category_territory)
        .with(motif_category_short_name, organisation_id)
      subject
    end

    it "is a success" do
      is_a_success
    end

    context "when the response is unsuccessful" do
      let(:response_body) { { error_messages: ["some error"] }.to_json }

      before do
        allow(rdv_solidarites_client).to receive(:create_motif_category_territory)
          .with(motif_category_short_name, organisation_id)
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
