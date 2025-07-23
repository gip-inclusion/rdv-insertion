describe "Agents can edit category configuration", :js do
  let!(:agent) { create(:agent) }
  let!(:organisation) { create(:organisation) }
  let!(:category_configuration) { create(:category_configuration, organisation: organisation) }
  let!(:agent_role) { create(:agent_role, organisation: organisation, agent: agent, access_level: "admin") }

  before do
    setup_agent_session(agent)
  end

  context "category configuration edit" do
    it "allows to edit category configuration" do
      visit edit_organisation_category_configuration_path(organisation, organisation.category_configurations.first)

      fill_in "category_configuration_phone_number", with: "3234"
      fill_in "category_configuration_email_to_notify_rdv_changes", with: "test@test.com"
      fill_in "category_configuration_email_to_notify_no_available_slots", with: "test@test.com"

      fill_in "category_configuration_template_rdv_title_override", with: "ceci est un rdv"

      click_button "Enregistrer"

      expect(page).to have_content("3234")
      expect(page).to have_content("test@test.com")
      expect(page).to have_content("ceci est un rdv")
      expect(page).to have_content("les invitations n'expireront jamais.")

      expect(category_configuration.reload.phone_number).to eq("3234")
      expect(category_configuration.email_to_notify_rdv_changes).to eq("test@test.com")
      expect(category_configuration.email_to_notify_no_available_slots).to eq("test@test.com")
      expect(category_configuration.template_rdv_title_override).to eq("ceci est un rdv")
    end
  end
end
