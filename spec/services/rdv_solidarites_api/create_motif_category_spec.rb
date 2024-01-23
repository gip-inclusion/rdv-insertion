describe RdvSolidaritesApi::CreateMotifCategory, type: :service do
  subject { described_class.call(motif_category_attributes: motif_category_attributes) }

  let!(:agent) { create(:agent) }
  let!(:motif_category_attributes) { { short_name: "rsa_orientation", name: "RSA Orientation" } }
  let!(:rdv_solidarites_client) { instance_double(RdvSolidaritesClient) }

  describe "#call" do
    before do
      allow(Current).to receive(:rdv_solidarites_client).and_return(rdv_solidarites_client)
      allow(rdv_solidarites_client).to receive(:create_motif_category)
        .and_return(OpenStruct.new(success?: true))
    end

    it "tries to create a motif" do
      expect(rdv_solidarites_client).to receive(:create_motif_category)
        .with(motif_category_attributes)
      subject
    end

    it "is a success" do
      is_a_success
    end

    context "when the response is unsuccessful" do
      let(:response_body) { { error_messages: ["some error"] }.to_json }

      before do
        allow(rdv_solidarites_client).to receive(:create_motif_category)
          .with(motif_category_attributes)
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
