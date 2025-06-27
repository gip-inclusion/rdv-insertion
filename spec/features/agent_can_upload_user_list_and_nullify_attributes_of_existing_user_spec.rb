describe "Agents can upload user list and nullify attributes of existing user", :js do
  include_context "with new file configuration"

  let!(:agent) { create(:agent, organisations: [organisation]) }
  let!(:department) { create(:department) }
  let!(:organisation) do
    create(
      :organisation,
      department:,
      category_configurations: [category_configuration]
    )
  end

  let!(:category_configuration) { create(:category_configuration, motif_category:, file_configuration:) }
  let!(:motif_category) { create(:motif_category) }

  before do
    setup_agent_session(agent)
  end

  context "when user already exists" do
    let!(:existing_user) do
      create(
        :user,
        first_name: "Hernan",
        last_name: "Crespo",
        email: "hernan@crespo.com",
        phone_number: "+33698943255",
        nir: "180333147687266",
        affiliation_number: "ISQCJQO",
        organisations: [organisation]
      )
    end

    it "can nullify user attributes by editing cells to empty values" do
      visit new_organisation_user_list_uploads_category_selection_path(organisation)

      expect(page).to have_content("Sélectionnez la catégorie de suivi sur laquelle importer les usagers")
      choose(motif_category.name)
      click_button("Valider")

      expect(page).to have_content("Choisissez un fichier usagers à charger")

      attach_file(
        "user_list_upload_file",
        Rails.root.join("spec/fixtures/new_fichier_usager_test.xlsx"),
        make_visible: true
      )

      expect(page).to have_content("new_fichier_usager_test.xlsx")
      expect(page).to have_content("2 usagers à importer")

      click_button("Charger les données usagers")

      expect(page).to have_content("Hernan", wait: 5)
      expect(page).to have_content("Crespo")

      expect(existing_user.phone_number).to eq("+33698943255")
      expect(existing_user.email).to eq("hernan@crespo.com")
      expect(existing_user.affiliation_number).to eq("ISQCJQO")

      table_row = find("tr", text: "Crespo")
      phone_cell = table_row.find("[data-user-row-attribute='phone_number']")
      phone_cell.double_click

      within(table_row) do
        fill_in "user_row[phone_number]", with: "", fill_options: { clear: :backspace }
        find("i.ri-check-line").click
      end

      expect(page).to have_no_content("+33698943255")

      table_row = find("tr", text: "Crespo")
      email_cell = table_row.find("[data-user-row-attribute='email']")
      email_cell.double_click

      within(table_row) do
        fill_in "user_row[email]", with: "", fill_options: { clear: :backspace }
        find("i.ri-check-line").click
      end

      expect(page).to have_no_content("hernan@crespo.com")

      table_row = find("tr", text: "Crespo")
      affiliation_cell = table_row.find("[data-user-row-attribute='affiliation_number']")
      affiliation_cell.double_click

      within(table_row) do
        fill_in "user_row[affiliation_number]", with: "", fill_options: { clear: :backspace }
        find("i.ri-check-line").click
      end

      expect(page).to have_no_content("ISQCJQO")
      expect(page).to have_no_css("form.edit-row-attribute", wait: 5)

      user_list_upload = UserListUpload.last

      hernan_row = user_list_upload.user_rows.find { |row| row.first_name == "Hernan" }

      expect(hernan_row.phone_number).to eq("[EDITED TO NULL]")
      expect(hernan_row.email).to eq("[EDITED TO NULL]")
      expect(hernan_row.affiliation_number).to eq("[EDITED TO NULL]")

      expect(hernan_row.user).to eq(existing_user)
      expect(hernan_row.user.phone_number).to be_nil
      expect(hernan_row.user.email).to be_nil
      expect(hernan_row.user.affiliation_number).to be_nil
    end
  end
end
