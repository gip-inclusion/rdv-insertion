describe "Agent can edit category configuration", :js do
  include ActionView::RecordIdentifier

  let!(:department) { create(:department) }
  let!(:organisation) { create(:organisation, department: department, organisation_type: "delegataire_rsa") }
  let!(:agent) { create(:agent, admin_role_in_organisations: [organisation]) }
  let!(:motif_category) do
    create(:motif_category, name: "RSA Orientation", short_name: "rsa_orientation",
                            motif_category_type: "rsa_orientation")
  end
  let!(:file_configuration) { create(:file_configuration, sheet_name: "Feuille Import", created_by_agent: agent) }
  let!(:category_configuration) do
    create(:category_configuration,
           organisation: organisation,
           motif_category: motif_category,
           file_configuration: file_configuration,
           phone_number: "0123456789",
           convene_user: true)
  end

  before do
    setup_agent_session(agent)
  end

  describe "accordion display" do
    it "expands accordion to show category details" do
      visit organisation_configuration_categories_path(organisation)

      expect(page).to have_content("« RSA Orientation »")
      expect(page).to have_no_content("Préférence de rendez-vous")

      find("[data-action='click->accordion#toggle']").click

      expect(page).to have_content("Préférence de rendez-vous")
      expect(page).to have_content("Fichier d'import")
      expect(page).to have_content("Notifications")
    end
  end

  describe "section editing" do
    it "edits rdv preferences via modal" do
      visit organisation_configuration_categories_path(organisation)

      find("[data-action='click->accordion#toggle']").click

      within("##{dom_id(category_configuration, :rdv_preferences)}") do
        click_link "Modifier"
      end

      expect(page).to have_content("Modifier les préférences de rendez-vous")

      fill_in "category_configuration_phone_number", with: "3949"

      click_button "Enregistrer"

      within("##{dom_id(category_configuration, :rdv_preferences)}") do
        expect(page).to have_content("3949")
      end

      expect(category_configuration.reload.phone_number).to eq("3949")
    end

    it "edits invitation settings via modal" do
      visit organisation_configuration_categories_path(organisation)

      find("[data-action='click->accordion#toggle']").click

      within("##{dom_id(category_configuration, :invitation_settings)}") do
        click_link "Modifier"
      end

      expect(page).to have_content("Modifier les préférences de messages de cette catégorie")

      fill_in "category_configuration_number_of_days_before_invitations_expire", with: "10"

      click_button "Enregistrer"

      expect(category_configuration.reload.number_of_days_before_invitations_expire).to eq(10)
    end

    it "edits alertings via modal" do
      visit organisation_configuration_categories_path(organisation)

      find("[data-action='click->accordion#toggle']").click

      within("##{dom_id(category_configuration, :alertings)}") do
        click_link "Modifier"
      end

      expect(page).to have_content("Notifier pour informer sur les prises de rendez-vous")

      fill_in "category_configuration_email_to_notify_rdv_changes", with: "notify@test.com"

      click_button "Enregistrer"

      expect(page).to have_content("notify@test.com")
      expect(category_configuration.reload.email_to_notify_rdv_changes).to eq("notify@test.com")
    end

    it "changes file import via modal" do
      new_file_config = create(:file_configuration, sheet_name: "Nouveau Fichier", created_by_agent: agent)

      visit organisation_configuration_categories_path(organisation)

      find("[data-action='click->accordion#toggle']").click

      within("##{dom_id(category_configuration, :file_configuration)}") do
        expect(page).to have_content("Feuille Import")
        click_link "Changer de modèle"
      end

      expect(page).to have_content("Changer le modèle de fichier")

      find("input[type='radio'][value='#{new_file_config.id}']").click
      click_button "Sélectionner ce modèle"

      within("##{dom_id(category_configuration, :file_configuration)}") do
        expect(page).to have_content("Nouveau Fichier")
      end

      expect(category_configuration.reload.file_configuration).to eq(new_file_config)
    end
  end

  describe "file configuration management" do
    context "when returning to selection modal" do
      it "returns to selection modal after viewing file configuration details" do
        visit organisation_configuration_categories_path(organisation)

        find("[data-action='click->accordion#toggle']").click
        click_link "Changer de modèle"

        within "turbo-frame#remote_modal" do
          click_link "Voir le détail"
        end

        expect(page).to have_content("Détails du fichier d'import")
        expect(page).to have_content("Feuille Import")

        click_link "Retour"

        expect(page).to have_content("Changer le modèle de fichier")
      end

      it "returns to selection modal when canceling file configuration creation" do
        visit organisation_configuration_categories_path(organisation)

        find("[data-action='click->accordion#toggle']").click
        click_link "Changer de modèle"

        within "turbo-frame#remote_modal" do
          click_link "Créer un nouveau modèle"
        end

        expect(page).to have_content("Créer un fichier d'import")

        click_link "Annuler"

        expect(page).to have_content("Changer le modèle de fichier")
      end

      it "returns to selection modal when canceling file configuration edit" do
        visit organisation_configuration_categories_path(organisation)

        find("[data-action='click->accordion#toggle']").click
        click_link "Changer de modèle"

        within "turbo-frame#remote_modal" do
          click_link "Modifier"
        end

        expect(page).to have_content("Modifier le modèle de fichier")

        click_link "Annuler"

        expect(page).to have_content("Changer le modèle de fichier")
      end
    end

    context "when saving (modal closes) (TODO: returns to selection modal in thoses cases ?)" do
      it "edits file configuration" do
        visit organisation_configuration_categories_path(organisation)

        find("[data-action='click->accordion#toggle']").click
        click_link "Changer de modèle"

        within "turbo-frame#remote_modal" do
          click_link "Modifier"
        end

        expect(page).to have_content("Modifier le modèle de fichier")

        fill_in "file_configuration_sheet_name", with: "Fichier Modifié"
        click_button "Enregistrer les modifications"

        expect(page).to have_content("Le fichier d'import a été modifié avec succès")
        expect(file_configuration.reload.sheet_name).to eq("Fichier Modifié")
      end

      it "creates a new file configuration" do
        visit organisation_configuration_categories_path(organisation)

        find("[data-action='click->accordion#toggle']").click
        click_link "Changer de modèle"

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
        expect(FileConfiguration.last.sheet_name).to eq("Nouveau Fichier")
      end
    end

    context "when agent cannot edit file configuration" do
      let!(:other_agent) { create(:agent) }
      let!(:other_organisation) { create(:organisation, department: department) }
      let!(:shared_file_configuration) do
        create(:file_configuration,
               sheet_name: "Fichier Partagé",
               created_by_agent: other_agent,
               category_configurations: [create(:category_configuration, organisation: other_organisation)])
      end

      before do
        category_configuration.update!(file_configuration: shared_file_configuration)
      end

      it "shows disabled edit button with tooltip" do
        visit organisation_configuration_categories_path(organisation)

        find("[data-action='click->accordion#toggle']").click
        click_link "Changer de modèle"

        within "turbo-frame#remote_modal", wait: 5 do
          expect(page).to have_content("Fichier Partagé")
          expect(page).to have_button("Modifier", disabled: true)
        end
      end
    end
  end
end
