describe "Agents can create category configuration", :js do
  let!(:agent) { create(:agent) }
  let!(:organisation) { create(:organisation, organisation_type: "delegataire_rsa") }
  let!(:agent_role) { create(:agent_role, organisation: organisation, agent: agent, access_level: "admin") }
  let!(:motif_category) do
    create(
      :motif_category,
      name: "RSA Suivi",
      short_name: "rsa_follow_up",
      motif_category_type: "rsa_accompagnement"
    )
  end

  let!(:file_configuration) { create(:file_configuration, created_by_agent: agent, category_configurations: []) }

  before do
    stub_rdv_solidarites_activate_motif_category_territories(
      organisation.rdv_solidarites_organisation_id,
      motif_category.short_name
    )
    setup_agent_session(agent)
  end

  context "category configuration creation" do
    it "allows to create category configuration" do
      visit new_organisation_category_configuration_path(organisation)

      fill_in "category_configuration_phone_number", with: "3234"
      fill_in "category_configuration_email_to_notify_rdv_changes", with: "test@test.com"
      fill_in "category_configuration_email_to_notify_no_available_slots", with: "test@test.com"

      select "RSA Suivi", from: "category_configuration[motif_category_id]"

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
          "category_configuration[motif_category_id]", options: ["-", "RSA Suivi"]
        )
      end
    end

    context "when no file configuration is available" do
      let!(:file_configuration) { nil }

      it "allows to create a fil configuration" do
        visit new_organisation_category_configuration_path(organisation)

        expect(page).to have_content("Créer et utiliser un nouveau fichier d'import")

        expect(FileConfiguration.count).to eq(0)

        click_link "Créer et utiliser un nouveau fichier d'import"

        expect(page).to have_content("Créer fichier d'import")

        fill_in "file_configuration_sheet_name", with: "Feuil1"
        fill_in "file_configuration_title_column", with: "Civilité"
        fill_in "file_configuration_first_name_column", with: "Prénom"
        fill_in "file_configuration_last_name_column", with: "Nom"
        fill_in "file_configuration_role_column", with: "Rôle"
        fill_in "file_configuration_email_column", with: "Email"

        within "turbo-frame#remote_modal" do
          click_button "Enregistrer"
        end

        expect(page).to have_content("Le fichier d'import a été créé avec succès", wait: 10)

        created_file_configuration = FileConfiguration.last
        expect(FileConfiguration.count).to eq(1)
        expect(created_file_configuration.sheet_name).to eq("Feuil1")
        expect(created_file_configuration.title_column).to eq("Civilité")
        expect(created_file_configuration.first_name_column).to eq("Prénom")
        expect(created_file_configuration.last_name_column).to eq("Nom")
        expect(created_file_configuration.role_column).to eq("Rôle")
        expect(created_file_configuration.email_column).to eq("Email")

        click_button "Fermer"

        expect(page).to have_content("Créé par vous il y a moins d'une minute", wait: 10)

        # we create now the category configuration with the newly created file configuration

        select "RSA Suivi", from: "category_configuration[motif_category_id]"

        find("input[name=\"category_configuration[file_configuration_id]\"]").click

        click_button "Enregistrer"

        expect(page).to have_content("Catégorie \"RSA Suivi\"")
        expect(page).to have_content("Contenu des messages")

        new_category_configuration = CategoryConfiguration.last
        expect(new_category_configuration.file_configuration_id).to eq(created_file_configuration.id)
      end
    end
  end
end
