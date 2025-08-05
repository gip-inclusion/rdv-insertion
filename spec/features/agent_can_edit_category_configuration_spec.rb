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

      expect(category_configuration.reload.phone_number).to eq("3234")
      expect(category_configuration.email_to_notify_rdv_changes).to eq("test@test.com")
      expect(category_configuration.email_to_notify_no_available_slots).to eq("test@test.com")
      expect(category_configuration.template_rdv_title_override).to eq("ceci est un rdv")
    end

    it "allows to see file configuration details" do
      visit edit_organisation_category_configuration_path(organisation, organisation.category_configurations.first)

      within "turbo-frame#file_configurations_list" do
        click_button "Voir le détail"
      end

      expect(page).to have_content("Détails du fichier d'import")
    end

    it "allows to edit file configuration" do
      visit edit_organisation_category_configuration_path(organisation, organisation.category_configurations.first)

      within "turbo-frame#file_configurations_list" do
        click_button "Modifier"
      end

      expect(page).to have_content("Modifier fichier d'import")

      fill_in "file_configuration_sheet_name", with: "Feuil2"

      click_button "Enregistrer"

      expect(page).to have_content("Le fichier d'import a été modifié avec succès", wait: 10)

      expect(category_configuration.reload.file_configuration.sheet_name).to eq("Feuil2")
    end

    it "allows to create a new file configuration" do
      visit edit_organisation_category_configuration_path(organisation, organisation.category_configurations.first)

      expect(page).to have_content("Créer et utiliser un nouveau fichier d'import")

      expect(FileConfiguration.count).to eq(1)

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
      expect(FileConfiguration.count).to eq(2)
      expect(created_file_configuration.sheet_name).to eq("Feuil1")
      expect(created_file_configuration.title_column).to eq("Civilité")
      expect(created_file_configuration.first_name_column).to eq("Prénom")
      expect(created_file_configuration.last_name_column).to eq("Nom")
      expect(created_file_configuration.role_column).to eq("Rôle")
      expect(created_file_configuration.email_column).to eq("Email")

      click_button "Fermer"

      expect(page).to have_content("Créé par vous il y a moins d'une minute", wait: 10)

      find("input[type='radio'][value='#{created_file_configuration.id}']").click
      click_button "Enregistrer"

      expect(page).to have_content("Catégorie \"#{category_configuration.motif_category.name}\"")
      expect(page).to have_content("Contenu des messages")

      expect(category_configuration.reload.file_configuration_id).to eq(created_file_configuration.id)
    end
  end
end
