describe "Agents can sort users on index page", :js do
  let!(:agent) { create(:agent, organisations: [organisation]) }
  let!(:organisation) { create(:organisation) }
  let!(:motif_category) { create(:motif_category, short_name: "rsa_orientation", name: "RSA orientation") }
  let!(:category_configuration) do
    create(:category_configuration, organisation: organisation, motif_category: motif_category)
  end
  let!(:motif) { create(:motif, motif_category: motif_category, organisation: organisation) }
  let!(:user1) { create(:user, first_name: "Bertrand", last_name: "Blier") }
  let!(:user2) { create(:user, first_name: "Amanda", last_name: "Ajer") }
  let!(:user3) { create(:user, first_name: "Claire", last_name: "Casubolo") }

  before do
    setup_agent_session(agent)
  end

  shared_examples "a properly filtered list" do |remaining_user, absent_user|
    it "filters users" do
      expect(page).to have_content("orientation")
      expect(page).to have_content(remaining_user)
      expect(page).to have_no_content(absent_user)
    end
  end

  context "on 'Tous les contacts' tab" do
    # on "Tous les contacts", users are sorted by user_org creation date by default
    let!(:users_organisation1) do
      create(:users_organisation, user: user1, organisation: organisation, created_at: Time.zone.now)
    end
    let!(:users_organisation2) do
      create(:users_organisation, user: user2, organisation: organisation, created_at: 1.day.ago)
    end
    let!(:users_organisation3) do
      create(:users_organisation, user: user3, organisation: organisation, created_at: 2.days.ago)
    end

    let!(:orientation) { create(:orientation, organisation: organisation, user: user1, orientation_type: "social") }

    before do
      visit organisation_users_path(organisation, orientation_type: "social")
    end

    it_behaves_like "a properly filtered list", "Bertrand", "Amanda"
  end

  context "on motif_category tab" do
    # on motif_category tab, users are sorted by follow_ups creation date by default
    let!(:organisation) { create(:organisation, users: [user1, user2, user3]) }
    let!(:follow_up1) { create(:follow_up, user: user1, motif_category: motif_category, created_at: Time.zone.now) }
    let!(:follow_up2) { create(:follow_up, user: user2, motif_category: motif_category, created_at: 1.day.ago) }
    let!(:follow_up3) { create(:follow_up, user: user3, motif_category: motif_category, created_at: 2.days.ago) }

    let!(:orientation) { create(:orientation, organisation: organisation, user: user2, orientation_type: "pro") }

    before do
      visit organisation_users_path(organisation, motif_category_id: motif_category.id, orientation_type: "pro")
    end

    it_behaves_like "a properly filtered list", "Amanda", "Bertrand"
  end
end
