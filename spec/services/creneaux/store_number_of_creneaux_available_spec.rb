describe Creneaux::StoreNumberOfCreneauxAvailable, type: :service do
  subject do
    described_class.call(category_configuration:)
  end

  let!(:category_configuration) { create(:category_configuration) }
  let!(:agent) { create(:agent, admin_role_in_organisations: [category_configuration.organisation]) }
  let!(:user) { create(:user) }
  let!(:follow_up) { create(:follow_up, user: user, motif_category: category_configuration.motif_category) }
  let!(:invitation) do
    create(:invitation, user: user, follow_up: follow_up, organisations: [category_configuration.organisation])
  end

  context "when API call succeeds" do
    before do
      allow(RdvSolidaritesApi::RetrieveCreneauAvailability).to receive(:call).and_return(
        OpenStruct.new(success?: true, creneau_availability_count: 3)
      )
    end

    it "stores the number of creneaux available" do
      subject
      expect(CreneauAvailability.last.number_of_creneaux_available).to eq(3)
      expect(CreneauAvailability.last.category_configuration).to eq(category_configuration)
    end

    it "stores the number of pending invitations" do
      subject
      expect(CreneauAvailability.last.number_of_pending_invitations).to eq(1)
    end
  end
end
