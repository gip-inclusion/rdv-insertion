describe "Agents can update contact info with caf file", js: true do
  let!(:agent) { create(:agent) }
  let!(:department) { create(:department) }
  let!(:organisation) do
    create(:organisation, agents: [agent], department: department, rdv_solidarites_organisation_id: "1122")
  end
  let!(:rdv_solidarites_user_id) { "232324" }

  before do
    setup_agent_session(agent)
    stub_rdv_solidarites_create_user(rdv_solidarites_user_id)
    stub_rdv_solidarites_update_user(rdv_solidarites_user_id)
    stub_send_in_blue
    stub_rdv_solidarites_get_organisation_user("1122", rdv_solidarites_user_id)
    stub_geo_api_request("127 RUE DE GRENELLE 75007 PARIS")
  end

  describe "when applicant is not created yet" do
    include_context "with file configuration"

    let!(:configuration) do
      create(:configuration, file_configuration: file_configuration, organisation: organisation)
    end

    it "updates the applicant list with the info from the csv file" do
      visit new_organisation_upload_path(organisation, configuration_id: configuration.id)

      attach_file("applicants-list-upload", Rails.root.join("spec/fixtures/fichier_allocataire_test.xlsx"))

      expect(page).to have_content("hernan@crespo.com")
      expect(page).to have_content("0620022002")

      click_button("Enrichir avec des données de contacts CNAF")

      attach_file("contact-file-upload", Rails.root.join("spec/fixtures/fichier_contact_test.csv"))

      expect(page).to have_content("hernan.crespo@hotmail.fr")
      expect(page).to have_content("698943255")

      click_button("Créer compte")

      expect(page).to have_button("Inviter par SMS", disabled: false)

      applicant = Applicant.last

      expect(applicant.email).to eq("hernan.crespo@hotmail.fr")
      expect(applicant.phone_number).to eq("+33698943255")
    end
  end

  describe "when the applicant is already created" do
    include_context "with file configuration"

    let!(:configuration) do
      create(:configuration, file_configuration: file_configuration, organisation: organisation)
    end

    let!(:applicant) do
      create(
        :applicant,
        first_name: "Hernan", last_name: "Crespo", email: "hernan@crespo.com", phone_number: "0620022002",
        affiliation_number: "ISQCJQO", organisations: [organisation], rdv_solidarites_user_id:
      )
    end

    it "can update the applicant attributes with the info from the csv file one by one" do
      visit new_organisation_upload_path(organisation, configuration_id: configuration.id)

      attach_file("applicants-list-upload", Rails.root.join("spec/fixtures/fichier_allocataire_test.xlsx"))

      expect(page).to have_content("hernan@crespo.com")
      expect(page).to have_content("+33620022002")

      expect(page).to have_css("i.fas.fa-link")
      expect(page).to have_selector(:css, "a[href=\"/organisations/#{organisation.id}/applicants/#{applicant.id}\"]")

      click_button("Enrichir avec des données de contacts CNAF")

      attach_file("contact-file-upload", Rails.root.join("spec/fixtures/fichier_contact_test.csv"))

      expect(page).to have_content("Nouvelles données trouvées pour Hernan Crespo")
      expect(page).to have_content("hernan.crespo@hotmail.fr")
      expect(page).to have_content("698943255")

      expect(page).to have_button("Mettre à jour").twice
      expect(page).to have_button("Tout mettre à jour")

      # it updates the email only
      click_on("Mettre à jour", match: :first)

      expect(page).to have_content("hernan.crespo@hotmail.fr")
      expect(page).not_to have_content("hernan@crespo.com")

      expect(applicant.reload.email).to eq("hernan.crespo@hotmail.fr")
      expect(applicant.reload.phone_number).to eq("+33620022002")

      click_button("Mettre à jour")

      expect(page).to have_content("+33698943255")
      expect(page).not_to have_content("+33620022002")

      expect(applicant.reload.phone_number).to eq("+33698943255")
    end

    it "can update all the attributes at once" do
      visit new_organisation_upload_path(organisation, configuration_id: configuration.id)

      attach_file("applicants-list-upload", Rails.root.join("spec/fixtures/fichier_allocataire_test.xlsx"))

      expect(page).to have_content("hernan@crespo.com")
      expect(page).to have_content("+33620022002")

      click_button("Enrichir avec des données de contacts CNAF")

      attach_file("contact-file-upload", Rails.root.join("spec/fixtures/fichier_contact_test.csv"))

      expect(page).to have_content("Nouvelles données trouvées pour Hernan Crespo")
      expect(page).to have_content("hernan.crespo@hotmail.fr")
      expect(page).to have_content("698943255")

      click_button("Tout mettre à jour")

      expect(page).to have_content("hernan.crespo@hotmail.fr")
      expect(page).to have_content("+33698943255")

      expect(applicant.reload.email).to eq("hernan.crespo@hotmail.fr")
      expect(applicant.reload.phone_number).to eq("+33698943255")
    end
  end
end
