describe CategoryConfigurations::StoreNumberOfCreneauxAvailable, type: :service do
  subject do
    described_class.call(category_configuration:)
  end

  let!(:category_configuration) { create(:category_configuration) }
  let!(:agent) { create(:agent, admin_role_in_organisations: [category_configuration.organisation]) }

  context "when API call succeeds" do
    before do
      allow(RdvSolidaritesApi::RetrieveCreneauAvailability).to(
        receive(:call).and_return(OpenStruct.new(creneau_availability_count: 3))
      )
    end

    it "stores the number of creneaux available" do
      subject
      expect(CreneauAvailability.last.number_of_creneaux_available).to eq(3)
      expect(CreneauAvailability.last.category_configuration).to eq(category_configuration)
    end
  end
end
