describe RdvSolidaritesApi::RetrieveMotifs, type: :service do
  subject do
    described_class.call(
      rdv_solidarites_session: rdv_solidarites_session,
      organisation: organisation
    )
  end

  let!(:rdv_solidarites_session) { instance_double(RdvSolidaritesSession) }
  let!(:rdv_solidarites_client) { instance_double(RdvSolidaritesClient) }
  let(:organisation) { create(:organisation, rdv_solidarites_organisation_id: 43, rsa_agents_service_id: "2") }

  describe "#call" do
    let!(:motifs) do
      [{
        "id" => 16,
        "location_type" => "public_office",
        "name" => "RSA - Orientation : rdv sur site"
      }]
    end

    before do
      allow(rdv_solidarites_session).to receive(:rdv_solidarites_client)
        .and_return(rdv_solidarites_client)
      allow(rdv_solidarites_client).to receive(:get_motifs)
        .with(43, "2")
        .and_return(OpenStruct.new(success?: true, body: { "motifs" => motifs }.to_json))
    end

    context "when it succeeds" do
      it("is a success") { is_a_success }

      it "retrieves the motifs" do
        expect(rdv_solidarites_client).to receive(:get_motifs)
          .with(43, "2")
        subject
      end

      it "returns the motifs" do
        expect(subject.motifs.map(&:id)).to contain_exactly(16)
      end
    end

    context "when it fails" do
      before do
        allow(rdv_solidarites_client).to receive(:get_motifs)
          .and_return(OpenStruct.new(success?: false, body: { error_messages: ['some error'] }.to_json))
      end

      it("is a failure") { is_a_failure }

      it "returns the error" do
        expect(subject.errors).to eq(["Erreur RDV-Solidarités: some error"])
      end
    end
  end
end
