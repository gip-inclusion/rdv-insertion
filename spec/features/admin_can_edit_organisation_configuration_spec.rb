describe "Admin can edit organisation configuration", :js do
  let!(:department) { create(:department) }
  let!(:organisation) do
    create(:organisation, department: department, name: "Organisation Test", phone_number: "0102030405",
                          email: "test@test.fr", slug: "org-test", data_retention_duration_in_months: 24,
                          rdv_solidarites_organisation_id: 123)
  end
  let!(:agent) { create(:agent, admin_role_in_organisations: [organisation]) }

  before do
    setup_agent_session(agent)
  end

  describe "informations tab" do
    it "displays organisation informations" do
      visit organisation_configuration_informations_path(organisation)

      expect(page).to have_content("Organisation Test")
      expect(page).to have_content("0102030405")
      expect(page).to have_content("test@test.fr")
      expect(page).to have_content("org-test")
    end

    it "allows to edit organisation informations" do
      stub_request(:patch, %r{/api/v1/organisations/}).to_return(
        status: 200,
        body: { organisation: { id: organisation.rdv_solidarites_organisation_id } }.to_json,
        headers: { "Content-Type" => "application/json" }
      )

      visit organisation_configuration_informations_path(organisation)

      within "turbo-frame#organisation_info" do
        click_link "Modifier"
      end

      fill_in "organisation_name", with: "Nouveau nom"
      fill_in "organisation_phone_number", with: "0607080910"
      fill_in "organisation_email", with: "nouveau@email.fr"

      click_button "Enregistrer"

      expect(page).to have_content("Nouveau nom")
      expect(page).to have_content("0607080910")
      expect(page).to have_content("nouveau@email.fr")

      expect(organisation.reload.name).to eq("Nouveau nom")
      expect(organisation.phone_number).to eq("0607080910")
      expect(organisation.email).to eq("nouveau@email.fr")
    end

    it "allows to edit data retention duration" do
      visit organisation_configuration_informations_path(organisation)

      within "turbo-frame#data_retention" do
        click_link "Modifier"
      end

      select "12", from: "organisation_data_retention_duration_in_months"

      click_button "Enregistrer"

      expect(page).to have_content("12 mois")
      expect(organisation.reload.data_retention_duration_in_months).to eq(12)
    end

    it "allows to upload a logo" do
      stub_request(:patch, %r{/api/v1/organisations/}).to_return(
        status: 200,
        body: { organisation: { id: organisation.rdv_solidarites_organisation_id } }.to_json,
        headers: { "Content-Type" => "application/json" }
      )

      visit organisation_configuration_informations_path(organisation)

      within "turbo-frame#organisation_info" do
        click_link "Modifier"
      end

      attach_file("logo_input", Rails.root.join("spec/fixtures/logo.png"), make_visible: true)

      expect(page).to have_css("[data-logo-upload-target='previewContainer']:not(.d-none)")

      click_button "Enregistrer"

      expect(page).to have_content("Logo de l'organisation")
      expect(page).to have_css("img[alt=\"Logo de l'organisation\"]")

      expect(organisation.reload.logo).to be_attached
    end
  end
end
