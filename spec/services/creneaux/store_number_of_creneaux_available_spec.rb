describe Creneaux::StoreNumberOfCreneauxAvailable, type: :service do
  subject do
    described_class.call(category_configuration:)
  end

  let!(:organisation) { create(:organisation) }
  let!(:category_configuration) { create(:category_configuration, organisation:) }
  let!(:agent_without_oauth_token) { create(:agent, admin_role_in_organisations: [organisation]) }
  let!(:agent_with_oauth_token) do
    create(:agent, :with_rdv_solidarites_oauth_token, admin_role_in_organisations: [organisation])
  end
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

    it "retrieves the creneaux as the agent with an oauth token" do
      expect(RdvSolidaritesApi::RetrieveCreneauAvailability).to receive(:call) do
        expect(Current.agent).to eq(agent_with_oauth_token)
        OpenStruct.new(success?: true, creneau_availability_count: 3)
      end
      subject
    end

    it "stores the number of creneaux available" do
      subject
      expect(CategoryConfiguration::CreneauAvailability.last.number_of_creneaux_available).to eq(3)
      expect(CategoryConfiguration::CreneauAvailability.last.category_configuration).to eq(category_configuration)
    end

    it "stores the number of pending invitations" do
      subject
      expect(CategoryConfiguration::CreneauAvailability.last.number_of_pending_invitations).to eq(1)
    end

    context "with multiple invitations of the same follow_up" do
      let!(:invitation2) do
        create(:invitation, user: user, follow_up: follow_up, organisations: [category_configuration.organisation])
      end

      it "stores the number of pending invitations" do
        subject
        expect(CategoryConfiguration::CreneauAvailability.last.number_of_pending_invitations).to eq(1)
      end
    end
  end
end
