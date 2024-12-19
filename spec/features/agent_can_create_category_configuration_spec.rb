describe "Agents can edit category configuration", :js do
  let!(:agent) { create(:agent) }
  let!(:organisation) { create(:organisation, organisation_type: "delegataire_rsa") }
  let!(:agent_role) { create(:agent_role, organisation: organisation, agent: agent, access_level: "admin") }
  let!(:motif_category) do
    create(
      :motif_category,
      name: "RSA Follow up",
      short_name: "rsa_follow_up",
      motif_category_type: "rsa_accompagnement"
    )
  end

  let!(:category_configuration) { create(:category_configuration, organisation:, file_configuration:) }
  let(:file_configuration) { create(:file_configuration) }

  before do
    stub_rdv_solidarites_activate_motif_category_territories(
      organisation.rdv_solidarites_organisation_id,
      motif_category.short_name
    )
    setup_agent_session(agent)
  end

  context "category configuration edit" do
    it "allows to create category configuration" do
      visit new_organisation_category_configuration_path(organisation)

      fill_in "category_configuration_phone_number", with: "3234"
      fill_in "category_configuration_email_to_notify_rdv_changes", with: "test@test.com"
      fill_in "category_configuration_email_to_notify_no_available_slots", with: "test@test.com"

      select "RSA Follow up", from: "category_configuration[motif_category_id]"

      find("input[name=\"category_configuration[file_configuration_id]\"]").click

      click_button "Enregistrer"

      expect(page).to have_content("3234")
      expect(page).to have_content("test@test.com")

      new_category_configuration = CategoryConfiguration.last
      expect(new_category_configuration.reload.phone_number).to eq("3234")
      expect(new_category_configuration.email_to_notify_rdv_changes).to eq("test@test.com")
      expect(new_category_configuration.email_to_notify_no_available_slots).to eq("test@test.com")
    end

    context "motif category selection" do
      let!(:motif_category2) do
        create(:motif_category, name: "Autre", short_name: "autre", motif_category_type: "autre")
      end

      it "allows to select authorized motif categories" do
        visit new_organisation_category_configuration_path(organisation)

        expect(page).to have_select(
          "category_configuration[motif_category_id]", options: ["-", "RSA Follow up",
                                                                 category_configuration.motif_category.name]
        )
      end
    end
  end
end
