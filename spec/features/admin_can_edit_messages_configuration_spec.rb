describe "Admin can edit messages configuration", :js do
  let!(:department) { create(:department, number: "26", name: "Drôme", capital: "Valence", pronoun: "la") }
  let!(:organisation) { create(:organisation, department: department, name: "Organisation Test") }
  let!(:messages_configuration) { organisation.messages_configuration }
  let!(:agent) { create(:agent, admin_role_in_organisations: [organisation]) }

  before do
    setup_agent_session(agent)
  end

  describe "messages configuration tab" do
    it "allows to edit messages configurations" do
      visit organisation_configuration_messages_path(organisation)

      within "turbo-frame#messages_configuration_#{messages_configuration.id}" do
        expect(page).to have_content("Identité de l'expéditeur")
        expect(page).to have_content("Le département de la Drôme") # default signature
        expect(page).to have_content("Organisation Test") # default direction_names
        expect(page).to have_content("Valence") # default sender_city (capital)
        expect(page).to have_content("le Conseil départemental") # default letter_sender_name
      end
      within "turbo-frame#messages_configuration_#{messages_configuration.id}" do
        click_link "Modifier"
      end

      expect(page).to have_field(
        "messages_configuration_sender_city",
        placeholder: "Valence (par défaut)"
      )
      expect(page).to have_field(
        "messages_configuration_letter_sender_name",
        placeholder: "le Conseil départemental (par défaut)"
      )

      fill_in "messages_configuration_sender_city", with: "Lyon"
      fill_in "messages_configuration_letter_sender_name", with: "le Président"
      fill_in "messages_configuration_help_address", with: "12 rue de la Mairie, 26000 Valence"

      check "Département"
      check "Européens"

      click_button "Enregistrer"

      expect(page).to have_content("Lyon")
      expect(page).to have_content("le Président")
      expect(page).to have_content("12 rue de la Mairie, 26000 Valence")
      expect(page).to have_content("Département")
      expect(page).to have_content("Européens")

      expect(messages_configuration.reload.sender_city).to eq("Lyon")
      expect(messages_configuration.letter_sender_name).to eq("le Président")
      expect(messages_configuration.logos_to_display).to include("department", "europe")
    end

    it "allows to add and edit signature lines" do
      visit organisation_configuration_messages_path(organisation)

      within "turbo-frame#messages_configuration_#{messages_configuration.id}" do
        click_link "Modifier"
      end

      # Fill first signature line
      signature_inputs = all("input[name='messages_configuration[signature_lines][]']")
      signature_inputs.first.fill_in with: "Cordialement"

      # Add a second signature line
      first("button", text: "Ajouter une ligne").click
      signature_inputs = all("input[name='messages_configuration[signature_lines][]']")
      signature_inputs.last.fill_in with: "L'équipe insertion"

      click_button "Enregistrer"

      within "turbo-frame#messages_configuration_#{messages_configuration.id}" do
        expect(page).to have_content("Cordialement")
        expect(page).to have_content("L'équipe insertion")
      end

      expect(messages_configuration.reload.signature_lines).to eq(["Cordialement", "L'équipe insertion"])
    end

    it "allows to add and edit direction names" do
      visit organisation_configuration_messages_path(organisation)

      within "turbo-frame#messages_configuration_#{messages_configuration.id}" do
        click_link "Modifier"
      end

      # Fill first direction name
      direction_inputs = all("input[name='messages_configuration[direction_names][]']")
      direction_inputs.first.fill_in with: "Direction de l'insertion"

      # Add a second direction name
      all("button", text: "Ajouter une ligne").last.click
      direction_inputs = all("input[name='messages_configuration[direction_names][]']")
      direction_inputs.last.fill_in with: "Service RSA"

      click_button "Enregistrer"

      within "turbo-frame#messages_configuration_#{messages_configuration.id}" do
        expect(page).to have_content("Direction de l'insertion")
        expect(page).to have_content("Service RSA")
      end

      expect(messages_configuration.reload.direction_names).to eq(["Direction de l'insertion", "Service RSA"])
    end

    it "allows to upload a signature image" do
      visit organisation_configuration_messages_path(organisation)

      expect(page).to have_content("Aucune signature jointe")

      within "turbo-frame#messages_configuration_#{messages_configuration.id}" do
        click_link "Modifier"
      end

      attach_file("signature_image_input", Rails.root.join("spec/fixtures/logo.png"), make_visible: true)

      expect(page).to have_css("[data-image-upload-target='previewContainer']:not(.d-none)")

      click_button "Enregistrer"

      expect(page).to have_css("img[alt='Signature jointe']")
      expect(messages_configuration.reload.signature_image).to be_attached
    end

    it "allows to remove a signature image" do
      messages_configuration.signature_image.attach(
        io: Rails.root.join("spec/fixtures/logo.png").open,
        filename: "logo.png"
      )

      visit organisation_configuration_messages_path(organisation)

      within "turbo-frame#messages_configuration_#{messages_configuration.id}" do
        click_link "Modifier"
      end

      expect(page).to have_css("[data-image-upload-target='previewContainer']:not(.d-none)")

      find("[data-action='click->image-upload#handleFileRemove']").click

      expect(page).to have_css("[data-image-upload-target='placeholder']:not(.d-none)")

      click_button "Enregistrer"

      expect(page).to have_content("Aucune signature jointe")
      expect(messages_configuration.reload.signature_image).not_to be_attached
    end

    it "allows to cancel editing" do
      messages_configuration.update!(sender_city: "Lyon")

      visit organisation_configuration_messages_path(organisation)

      within "turbo-frame#messages_configuration_#{messages_configuration.id}" do
        click_link "Modifier"
      end

      fill_in "messages_configuration_sender_city", with: "Paris"

      click_link "Annuler"

      expect(page).to have_content("Lyon")
      expect(page).to have_no_content("Paris")
      expect(messages_configuration.reload.sender_city).to eq("Lyon")
    end

    it "clears custom value to use default when field is emptied" do
      messages_configuration.update!(sender_city: "Lyon")

      visit organisation_configuration_messages_path(organisation)

      within "turbo-frame#messages_configuration_#{messages_configuration.id}" do
        click_link "Modifier"
      end

      fill_in "messages_configuration_sender_city", with: ""

      click_button "Enregistrer"

      # Should display default value (capital)
      expect(page).to have_content("Valence")
      expect(messages_configuration.reload.sender_city).to be_nil
    end
  end
end
