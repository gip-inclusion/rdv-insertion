describe RdvSolidaritesApi::UpdateOrganisation, type: :service do
  subject do
    described_class.call(organisation_attributes:, rdv_solidarites_organisation_id: rdv_solidarites_organisation_id)
  end

  let(:rdv_solidarites_client) { instance_double(RdvSolidaritesClient) }
  let(:organisation_attributes) do
    { name: "PIE Pantin", email: "pie@pantin.fr", phone_number: "0102030405" }
  end
  let(:rdv_solidarites_organisation_id) { 1 }

  describe "#call" do
    let(:response_body) do
      { organisation: organisation_attributes.merge(id: 1) }.to_json
    end

    let(:parsed_response) { JSON.parse(response_body) }

    before do
      allow(Current).to receive(:rdv_solidarites_client).and_return(rdv_solidarites_client)
      allow(rdv_solidarites_client).to receive(:update_organisation)
        .with(rdv_solidarites_organisation_id, organisation_attributes)
        .and_return(OpenStruct.new(body: response_body))
    end

    it "tries to update a user in rdv solidarites" do
      expect(rdv_solidarites_client).to receive(:update_organisation)
        .with(rdv_solidarites_organisation_id, organisation_attributes)
      subject
    end

    context "when the response is successful" do
      let(:rdv_solidarites_organisation) { instance_double(RdvSolidarites::Organisation) }

      before do
        allow(rdv_solidarites_client).to receive(:update_organisation)
          .with(rdv_solidarites_organisation_id, organisation_attributes)
          .and_return(OpenStruct.new(body: response_body, success?: true))
        allow(RdvSolidarites::Organisation).to receive(:new)
          .with(parsed_response["organisation"])
          .and_return(rdv_solidarites_organisation)
      end

      it "is a success" do
        is_a_success
      end

      it "stores the rdv solidarites organisation" do
        expect(subject.organisation).to eq(rdv_solidarites_organisation)
      end
    end

    context "when the response is unsuccessful" do
      let(:response_body) { { error_messages: ["some error"] }.to_json }

      before do
        allow(rdv_solidarites_client).to receive(:update_organisation)
          .with(rdv_solidarites_organisation_id, organisation_attributes)
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
