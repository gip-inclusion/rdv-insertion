describe RdvSolidaritesApi::RetrieveOrganisations, type: :service do
  subject do
    described_class.call
  end

  let(:rdv_solidarites_client) { instance_double(RdvSolidaritesClient) }

  describe "#call" do
    let!(:organisations) do
      [{
        "id" => 16,
        "name" => "Conseil départemental de l'Yonne"
      }]
    end

    before do
      allow(Current).to receive(:rdv_solidarites_client).and_return(rdv_solidarites_client)
      allow(rdv_solidarites_client).to receive(:get_organisations)
        .with({})
        .and_return(OpenStruct.new(success?: true, body: { "organisations" => organisations }.to_json))
    end

    context "when it succeeds" do
      it("is a success") { is_a_success }

      it "retrieves the motifs" do
        expect(rdv_solidarites_client).to receive(:get_organisations)
        subject
      end

      it "returns the organisations" do
        expect(subject.organisations.map(&:id)).to contain_exactly(16)
      end
    end

    context "when it fails" do
      before do
        allow(rdv_solidarites_client).to receive(:get_organisations)
          .and_return(OpenStruct.new(success?: false, body: { error_messages: ["some error"] }.to_json))
      end

      it("is a failure") { is_a_failure }

      it "returns the error" do
        expect(subject.errors).to eq(["Erreur RDV-Solidarités: some error"])
      end
    end

    context "with geo attributes" do
      subject do
        described_class.call(geo_attributes:)
      end

      let!(:geo_attributes) { { city_code: "26323" } }

      before do
        allow(rdv_solidarites_client).to receive(:get_organisations)
          .with(geo_attributes)
          .and_return(OpenStruct.new(success?: true, body: { "organisations" => organisations }.to_json))
      end

      it("is a success") { is_a_success }

      it "retrieves the geolocated organisations" do
        expect(rdv_solidarites_client).to receive(:get_organisations).with(geo_attributes)
        subject
      end

      it "returns the geolocated organisations" do
        expect(subject.organisations.map(&:id)).to contain_exactly(16)
      end
    end
  end
end
