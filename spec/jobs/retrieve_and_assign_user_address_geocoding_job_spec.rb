describe RetrieveAndAssignUserAddressGeocodingJob do
  subject do
    described_class.new.perform(user.id)
  end

  let!(:user) { create(:user, address:, organisations: [organisation], address_geocoding: nil) }
  let!(:address) { "78940 garancières la queue 28 rue la Garance" }
  let!(:organisation) { create(:organisation, department:) }
  let!(:department) { create(:department, number: "78") }
  let!(:geocoding_params) do
    {
      street_ban_id: "78513_0053",
      post_code: "78940",
      city_code: "78513",
      longitude: 1.759386,
      latitude: 48.804796,
      city: "La Queue-les-Yvelines",
      street: "Rue de la Garance",
      house_number: "28"
    }
  end

  before do
    allow(RetrieveAddressGeocodingParams).to receive(:call)
      .with(address:, department_number: "78")
      .and_return(OpenStruct.new(success?: true, geocoding_params:))
  end

  it "creates a geocoding record and assigns it to the user" do
    expect { subject }.to change(AddressGeocoding, :count).by(1)
    geocoding = user.reload.address_geocoding
    expect(geocoding.symbolized_attributes).to match(hash_including(geocoding_params))
  end

  context "when the user has a geocoding attached already" do
    let!(:address_geocoding) { create(:address_geocoding, user:) }

    it "updates the assigned geocoding with the retrieved geocoding params" do
      expect { subject }.not_to change(AddressGeocoding, :count)
      expect(address_geocoding.reload.symbolized_attributes).to match(hash_including(geocoding_params))
      expect(address_geocoding.user_id).to eq(user.id)
    end

    context "when no geocoding params could be retrieved" do
      before do
        allow(RetrieveAddressGeocodingParams).to receive(:call)
          .with(address:, department_number: "78")
          .and_return(OpenStruct.new(success?: true, geocoding_params: nil))
      end

      it "destroys the associated geocoding" do
        expect { subject }.to change(AddressGeocoding, :count).by(-1)
        expect(user.reload.address_geocoding).to be_nil
      end
    end
  end

  context "when the user is multiple departments" do
    let!(:user) do
      create(:user, address:, organisations: [yvelines_organisation, drome_organisation], address_geocoding: nil)
    end
    let!(:yvelines_organisation) { create(:organisation, department: yvelines_department) }
    let!(:yvelines_department) { create(:department, number: "78") }
    let!(:drome_organisation) { create(:organisation, department: drome_department) }
    let!(:drome_department) { create(:department, number: "26") }

    context "when the address points to one department" do
      let!(:address) { "78940 garancières la queue 28 rue la Garance" }

      before do
        allow(RetrieveAddressGeocodingParams).to receive(:call)
          .with(address:, department_number: "78")
          .and_return(OpenStruct.new(success?: true, geocoding_params:))
      end

      it "retrieves the geocoding_params from one department only" do
        expect(RetrieveAddressGeocodingParams).to receive(:call)
          .with(address:, department_number: "78")
        expect(RetrieveAddressGeocodingParams).not_to receive(:call)
          .with(address:, department_number: "26")
        subject
        expect(user.reload.address_geocoding.symbolized_attributes).to match(hash_including(geocoding_params))
      end
    end

    context "when the address does not point to any depart ment" do
      let!(:address) { "28 rue la Garance" }

      before do
        allow(RetrieveAddressGeocodingParams).to receive(:call)
          .with(address:, department_number: "78")
          .and_return(OpenStruct.new(success?: true, geocoding_params: nil))
        allow(RetrieveAddressGeocodingParams).to receive(:call)
          .with(address:, department_number: "26")
          .and_return(OpenStruct.new(success?: true, geocoding_params:))
      end

      it "tries to retrieve the geocoding from the two different departments" do
        expect(RetrieveAddressGeocodingParams).to receive(:call)
          .with(address:, department_number: "78")
        expect(RetrieveAddressGeocodingParams).to receive(:call)
          .with(address:, department_number: "26")
        subject
        expect(user.reload.address_geocoding.symbolized_attributes).to match(hash_including(geocoding_params))
      end

      context "when no address could be retrieved" do
        before do
          allow(RetrieveAddressGeocodingParams).to receive(:call)
            .with(address:, department_number: "78")
            .and_return(OpenStruct.new(success?: true, geocoding_params: nil))
          allow(RetrieveAddressGeocodingParams).to receive(:call)
            .with(address:, department_number: "26")
            .and_return(OpenStruct.new(success?: true, geocoding_params: nil))
        end

        it "does not attach an address geocoding" do
          expect(RetrieveAddressGeocodingParams).to receive(:call)
            .with(address:, department_number: "78")
          expect(RetrieveAddressGeocodingParams).to receive(:call)
            .with(address:, department_number: "26")
          subject
          expect(user.reload.address_geocoding).to be_nil
        end
      end
    end
  end
end
