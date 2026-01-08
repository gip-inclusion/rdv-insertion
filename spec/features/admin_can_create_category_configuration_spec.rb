describe "Agent can create category configuration", :js do
  let!(:department) { create(:department) }
  let!(:organisation) { create(:organisation, department: department, organisation_type: "delegataire_rsa") }
  let!(:agent) { create(:agent, admin_role_in_organisations: [organisation]) }
  let!(:motif_category) do
    create(:motif_category, name: "RSA Orientation", short_name: "rsa_orientation",
                            motif_category_type: "rsa_orientation")
  end

  before do
    stub_rdv_solidarites_activate_motif_category_territories(
      organisation.rdv_solidarites_organisation_id,
      motif_category.short_name
    )
    setup_agent_session(agent)
  end

  describe "empty state" do
    it "displays empty state when no categories exist" do
      visit organisation_configuration_categories_path(organisation)

      expect(page).to have_content("Catégories de motifs")
      expect(page).to have_content("Il n'y a pas encore de catégorie configurée pour cette organisation")
      expect(page).to have_link("ajoutez une catégorie de motifs")
    end

    it "navigates to new category page from empty state link" do
      visit organisation_configuration_categories_path(organisation)

      click_link "ajoutez une catégorie de motifs"

      expect(page).to have_content("Ajouter une catégorie")
    end
  end

  describe "category creation" do
    let!(:file_configuration) { create(:file_configuration, sheet_name: "Import RSA", created_by_agent: agent) }

    it "creates a category with all fields filled" do
      visit new_organisation_category_configuration_path(organisation)

      expect(page).to have_content("Ajouter une catégorie de motifs")

      find("button[data-dropdown--select-option-target='button']").click
      find("div[data-dropdown--select-option-target='option']", text: "RSA Orientation").click

      fill_in "category_configuration_phone_number", with: "3949"
      fill_in "category_configuration_number_of_days_before_invitations_expire", with: "15"

      within("#file_configuration_selection") do
        click_link "Sélectionner un modèle de fichier"
      end

      within "turbo-frame#remote_modal" do
        find("input[type='radio'][value='#{file_configuration.id}']").click
        click_button "Sélectionner ce modèle"
      end

      fill_in "category_configuration_email_to_notify_rdv_changes", with: "rdv@test.com"
      fill_in "category_configuration_email_to_notify_no_available_slots", with: "slots@test.com"

      click_button "Ajouter la catégorie"

      expect(page).to have_content("« RSA Orientation »")

      new_category = CategoryConfiguration.last
      expect(new_category.phone_number).to eq("3949")
      expect(new_category.number_of_days_before_invitations_expire).to eq(15)
      expect(new_category.email_to_notify_rdv_changes).to eq("rdv@test.com")
      expect(new_category.email_to_notify_no_available_slots).to eq("slots@test.com")
      expect(new_category.file_configuration).to eq(file_configuration)
    end

    it "creates a category by creating a new file configuration" do
      visit new_organisation_category_configuration_path(organisation)

      find("button[data-dropdown--select-option-target='button']").click
      find("div[data-dropdown--select-option-target='option']", text: "RSA Orientation").click

      within("#file_configuration_selection") do
        click_link "Sélectionner un modèle de fichier"
      end

      within "turbo-frame#remote_modal" do
        click_link "Créer un nouveau modèle"
      end

      expect(page).to have_content("Créer un fichier d'import")

      fill_in "file_configuration_sheet_name", with: "Nouveau Fichier"
      fill_in "file_configuration_title_column", with: "Civilité"
      fill_in "file_configuration_first_name_column", with: "Prénom"
      fill_in "file_configuration_last_name_column", with: "Nom"
      click_button "Créer"

      expect(page).to have_content("Le fichier d'import a été créé avec succès")

      created_file_configuration = FileConfiguration.last
      expect(created_file_configuration.sheet_name).to eq("Nouveau Fichier")

      click_button "Fermer"

      within("#file_configuration_selection") do
        click_link "Sélectionner un modèle de fichier"
      end

      within "turbo-frame#remote_modal" do
        find("input[type='radio'][value='#{created_file_configuration.id}']").click
        click_button "Sélectionner ce modèle"
      end

      expect(page).to have_content("Modèle sélectionné")
      expect(page).to have_content("Nouveau Fichier")

      click_button "Ajouter la catégorie"

      expect(page).to have_content("« RSA Orientation »")
      expect(CategoryConfiguration.last.file_configuration).to eq(created_file_configuration)
    end

    context "motif category filtering" do
      let!(:unauthorized_motif_category) do
        create(:motif_category, name: "Autre", short_name: "autre", motif_category_type: "autre")
      end

      it "only shows motif categories authorized for the organisation type" do
        visit new_organisation_category_configuration_path(organisation)

        find("button[data-dropdown--select-option-target='button']").click

        expect(page).to have_css("div[data-dropdown--select-option-target='option']", text: "RSA Orientation")
        expect(page).to have_no_css("div[data-dropdown--select-option-target='option']", text: "Autre")
      end
    end
  end
end
