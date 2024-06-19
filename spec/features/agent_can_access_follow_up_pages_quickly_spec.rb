describe "Agents can access follow up pages quickly", :js do
  let!(:agent) { create(:agent, organisations: [organisation]) }
  let!(:organisation) { create(:organisation) }
  let!(:motif_category) { create(:motif_category, short_name: "rsa_orientation", name: "RSA orientation") }
  let!(:category_configuration) do
    create(:category_configuration, organisation: organisation, motif_category: motif_category)
  end
  let!(:motif) { create(:motif, motif_category: motif_category, organisation: organisation) }
  let!(:user1) { create(:user, first_name: "Bertrand", last_name: "Blier") }
  let!(:follow_up) do
    create(:follow_up, user: user1, motif_category: motif_category)
  end

  before do
    setup_agent_session(agent)
  end

  context "on 'Tous les contacts' tab" do
    let!(:users_organisation1) do
      create(:users_organisation, user: user1, organisation: organisation, created_at: Time.zone.now)
    end

    before do
      visit organisation_users_path(organisation)
    end

    it "redirects to the follow up page" do
      find("td", text: "Non invité").click
      expect(page).to have_current_path(organisation_user_follow_ups_path(user_id: user1.id,
                                                                          organisation_id: organisation.id))
    end
  end

  context "on motif_category tab" do
    let!(:organisation) { create(:organisation, users: [user1]) }

    before do
      visit organisation_users_path(organisation, motif_category_id: motif_category.id)
    end

    it "redirects to the follow up page" do
      find("td", text: "Non invité").click
      expect(page).to have_current_path(organisation_user_follow_ups_path(user_id: user1.id,
                                                                          organisation_id: organisation.id))
    end
  end
end
