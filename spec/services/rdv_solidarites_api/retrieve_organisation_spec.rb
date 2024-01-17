describe RdvSolidaritesApi::RetrieveOrganisation, type: :service do
  subject do
    described_class.call(rdv_solidarites_organisation_id:)
  end

  let(:rdv_solidarites_client) { instance_double(RdvSolidaritesClient) }
  let!(:rdv_solidarites_organisation_id) { 1717 }

  describe "#call" do
    let!(:organisation) do
      {
        "id" => 1717,
        "name" => "Conseil départemental de l'Yonne",
        "phone_number" => "0102030405"
      }
    end

    before do
      allow(Current).to receive(:rdv_solidarites_client).and_return(rdv_solidarites_client)
      allow(rdv_solidarites_client).to receive(:get_organisation)
        .with(rdv_solidarites_organisation_id)
        .and_return(OpenStruct.new(success?: true, body: { "organisation" => organisation }.to_json))
    end

    context "when it succeeds" do
      it("is a success") { is_a_success }

      it "calls the rdv solidarites client" do
        expect(rdv_solidarites_client).to receive(:get_organisation)
        subject
      end

      it "returns the organisation" do
        expect(subject.organisation.id).to eq(rdv_solidarites_organisation_id)
        expect(subject.organisation.name).to eq("Conseil départemental de l'Yonne")
        expect(subject.organisation.phone_number).to eq("0102030405")
      end
    end

    context "when it fails" do
      before do
        allow(rdv_solidarites_client).to receive(:get_organisation)
          .and_return(OpenStruct.new(success?: false, body: { error_messages: ["some error"] }.to_json))
      end

      it("is a failure") { is_a_failure }

      it "returns the error" do
        expect(subject.errors).to eq(["Erreur RDV-Solidarités: some error"])
      end
    end
  end
end
