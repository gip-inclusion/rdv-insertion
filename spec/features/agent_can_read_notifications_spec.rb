describe "Agents can read notifications", :js do
  let!(:agent) { create(:agent, organisations: [organisation]) }
  let!(:organisation) { create(:organisation) }
  let!(:motif_category) { create(:motif_category, short_name: "rsa_orientation", name: "RSA orientation") }
  let!(:category_configuration) do
    create(:category_configuration, organisation: organisation, motif_category: motif_category)
  end
  let!(:motif) { create(:motif, motif_category: motif_category, organisation: organisation) }
  let!(:user1) { create(:user, first_name: "Bertrand", last_name: "Blier") }
  let!(:creneau_availability) do
    create(:creneau_availability,
           category_configuration:,
           number_of_creneaux_available: 4,
           number_of_pending_invitations: 8)
  end

  context "agent has notifications but hasn't opened them yet" do
    before do
      setup_agent_session(agent)
      visit organisation_users_path(organisation)
    end

    it "can see notifications" do
      expect(page).to have_css("#btn-notification-center.has-notification")

      find_by_id("btn-notification-center").click

      expect(page).to have_css("#notification-center-dropdown")
      expect(find_by_id("notification-center-dropdown")).to be_visible
      expect(page).to have_content("Notifications")

      within("#notification_center_content") do
        expect(page).to have_content("Il n'y a pas suffisamment de créneaux")
        expect(page).to have_content(motif_category.name)
      end

      find_by_id("notification-center-close").click

      expect(find_by_id("notification-center-dropdown", visible: false)).not_to be_visible
      expect(page).to have_no_css("#btn-notification-center.has-notification")
    end
  end

  context "agent has read all notifications" do
    before do
      visit "/"
      page.driver.browser.manage.add_cookie(name: "most_recent_notification_read", value: 1.hour.from_now.to_i.to_s)
      page.driver.browser.manage.add_cookie(name: "oldest_notification_read", value: 1.hour.ago.to_i.to_s)

      setup_agent_session(agent)
      visit organisation_users_path(organisation)
    end

    it "doesn't see notification indicator" do
      expect(page).to have_no_css("#btn-notification-center.has-notification")
    end
  end
end
