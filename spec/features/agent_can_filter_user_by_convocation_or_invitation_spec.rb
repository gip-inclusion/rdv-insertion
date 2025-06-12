describe "Agents can filter users by convocation or invitation on index page", :js do
  let!(:department) { create(:department) }
  let!(:agent) { create(:agent, organisations: [organisation]) }
  let!(:organisation) { create(:organisation, department:) }
  let!(:motif_category) { create(:motif_category, short_name: "rsa_orientation", name: "RSA orientation") }
  let!(:category_configuration) do
    create(:category_configuration, organisation: organisation, motif_category: motif_category)
  end
  let!(:motif) { create(:motif, motif_category: motif_category, organisation: organisation) }
  let!(:user1) { create(:user, first_name: "Bertrand", last_name: "Blier", department: department) }
  let!(:user2) { create(:user, first_name: "Amanda", last_name: "Ajer", department: department) }
  let!(:user3) { create(:user, first_name: "Claire", last_name: "Casubolo", department: department) }

  let!(:users_organisation1) do
    create(:users_organisation, user: user1, organisation: organisation, created_at: Time.zone.now)
  end
  let!(:users_organisation2) do
    create(:users_organisation, user: user2, organisation: organisation, created_at: 1.day.ago)
  end
  let!(:users_organisation3) do
    create(:users_organisation, user: user3, organisation: organisation, created_at: 2.days.ago)
  end

  let(:follow_up) { create(:follow_up, user: user3, motif_category:) }
  let(:participation) { create(:participation, user: user3, follow_up:, convocable: true) }
  let!(:notification) { create(:notification, participation:, created_at: 3.days.ago) }

  let(:follow_up2) { create(:follow_up, user: user1, motif_category:) }
  let(:participation2) { create(:participation, user: user1, follow_up: follow_up2, convocable: true) }
  let!(:notification2) { create(:notification, participation: participation2, created_at: 1.day.ago) }

  before do
    follow_up.set_status
    follow_up.save
    follow_up2.set_status
    follow_up2.save
  end

  context "with convocation date before" do
    before do
      setup_agent_session(agent)
      visit organisation_users_path(
        organisation,
        convocation_date_before: 2.days.ago,
        motif_category_id: motif_category.id
      )
    end

    it "filters users" do
      expect(page).to have_no_content(user1.first_name)
      expect(page).to have_no_content(user2.first_name)
      expect(page).to have_content(user3.first_name)
    end
  end

  context "with convocation date after" do
    before do
      setup_agent_session(agent)
      visit organisation_users_path(organisation, convocation_date_after: 2.days.ago,
                                                  motif_category_id: motif_category.id)
    end

    it "filters users" do
      expect(page).to have_content(user1.first_name)
      expect(page).to have_no_content(user2.first_name)
      expect(page).to have_no_content(user3.first_name)
    end
  end

  context "with convocation date before and after" do
    before do
      setup_agent_session(agent)
      visit organisation_users_path(organisation, convocation_date_before: 2.days.ago,
                                                  convocation_date_after: 4.days.ago,
                                                  motif_category_id: motif_category.id)
    end

    it "filters users" do
      expect(page).to have_no_content(user1.first_name)
      expect(page).to have_no_content(user2.first_name)
      expect(page).to have_content(user3.first_name)
    end
  end
end
