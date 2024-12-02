describe RetrieveOrganisationsFromAddress, type: :service do
  subject { described_class.call(address: address, department_number: department_number) }

  let(:address) { "123 Main St" }
  let(:department_number) { "75" }
  let(:geocoding_params) { { city_code: "13444" } }
  let(:rdv_solidarites_organisations) do
    [instance_double("Organisation", id: 1131), instance_double("Organisation", id: 1132)]
  end
  let!(:matching_organisations) do
    [create(:organisation, rdv_solidarites_organisation_id: 1131),
     create(:organisation, rdv_solidarites_organisation_id: 1132)]
  end

  describe "#call" do
    before do
      allow(RetrieveAddressGeocodingParams).to receive(:call)
        .with(address: address, department_number: department_number)
        .and_return(OpenStruct.new(success?: true, geocoding_params: geocoding_params))

      allow(RdvSolidaritesApi::RetrieveOrganisations).to receive(:call)
        .with(geo_attributes: geocoding_params)
        .and_return(OpenStruct.new(success?: true, organisations: rdv_solidarites_organisations))
    end

    context "when address is present" do
      it("is a success") { is_a_success }

      it "returns organisations matching the RDV-Solidarites IDs" do
        expect(subject.organisations).to eq(matching_organisations)
      end
    end

    context "when address is blank" do
      let(:address) { "" }

      it("is a failure") { is_a_failure }

      it "includes the correct error message" do
        expect(subject.errors).to include("Impossible de trouver une organisation sans adresse")
      end
    end

    context "when geocoding params retrieval fails" do
      before do
        allow(RetrieveAddressGeocodingParams).to receive(:call)
          .and_return(OpenStruct.new(success?: false, errors: ["Geocoding error"]))
      end

      it("is a failure") { is_a_failure }

      it "includes the geocoding service errors" do
        expect(subject.errors).to include("Geocoding error")
      end
    end

    context "when RDV-Solidarites API call fails" do
      before do
        allow(RdvSolidaritesApi::RetrieveOrganisations).to receive(:call)
          .and_return(OpenStruct.new(success?: false, errors: ["API error"]))
      end

      it("is a failure") { is_a_failure }

      it "includes the API service errors" do
        expect(subject.errors).to include("API error")
      end
    end
  end
end
