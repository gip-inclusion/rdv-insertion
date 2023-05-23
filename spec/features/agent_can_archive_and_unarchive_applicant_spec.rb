describe "Agents can archive and unarchive applicant", js: true do
  let!(:agent) { create(:agent) }
  let!(:department) { create(:department) }
  let!(:organisation) { create(:organisation, agents: [agent], department: department) }
  let!(:applicant) do
    create(:applicant, organisations: [organisation])
  end

  before { setup_agent_session(agent) }

  describe "from show page" do
    it "can archive and unarchive the applicant" do
      visit organisation_applicant_path(organisation, applicant)
      expect(page).to have_button("Archiver le dossier")

      click_button("Archiver le dossier")

      expect(page).to have_content("Le dossier sera archivé sur toutes les organisations")
      fill_in "Motif d'archivage:", with: "déménagement"

      click_button "Oui"

      expect(page).to have_content "Dossier archivé"
      expect(page).to have_content "Motif d'archivage"
      expect(page).to have_content "déménagement"

      expect(Archive.count).to eq(1)

      expect(page).to have_button "Rouvrir le dossier"
      click_button "Rouvrir le dossier"
      expect(page).to have_content "Le dossier sera rouvert"
      click_button "Oui"

      expect(page).not_to have_content "Dossier archivé"
      expect(page).not_to have_content "Motif d'archivage"
      expect(page).not_to have_content "déménagement"

      expect(page).to have_content("Archiver le dossier")

      expect(Archive.count).to eq(0)
    end

    context "when the applicant is archived in another department" do
      let!(:other_department) { create(:department) }
      let!(:other_org) { create(:organisation, department: other_department, applicants: [applicant]) }
      let!(:archive) { create(:archive, applicant: applicant, department: create(:department)) }

      it "can still archive in agent department" do
        visit department_applicant_path(department, applicant)
        expect(page).to have_button("Archiver le dossier")

        click_button("Archiver le dossier")

        expect(page).to have_content("Le dossier sera archivé sur toutes les organisations")
        fill_in "Motif d'archivage:", with: "déménagement"

        click_button "Oui"

        expect(page).to have_content "Dossier archivé"
        expect(page).to have_content "Motif d'archivage"
        expect(page).to have_content "déménagement"

        expect(Archive.count).to eq(2)

        expect(page).to have_button "Rouvrir le dossier"
        click_button "Rouvrir le dossier"
        expect(page).to have_content "Le dossier sera rouvert"
        click_button "Oui"

        expect(page).not_to have_content "Dossier archivé"
        expect(page).not_to have_content "Motif d'archivage"
        expect(page).not_to have_content "déménagement"

        expect(page).to have_content("Archiver le dossier")

        expect(Archive.count).to eq(1)
      end
    end

    context "when the agent does not belong to all applicants orgs inside the deparment" do
      let!(:other_org) { create(:organisation, department: department, applicants: [applicant]) }

      it "is not allowed to archive the applicant" do
        visit organisation_applicant_path(organisation, applicant)

        expect(page).to have_button("Archiver le dossier", disabled: true)
      end
    end
  end

  describe "from upload page" do
    include_context "with file configuration"

    let!(:configuration) do
      create(:configuration, file_configuration: file_configuration, organisation: organisation)
    end
    let!(:applicant) do
      create(
        :applicant,
        email: "hernan@crespo.com",
        first_name: "hernan",
        organisations: [organisation]
      )
    end
    let!(:archive) do
      create(:archive, applicant: applicant, department: department, archiving_reason: "CDI")
    end

    it "can unarchive an applicant" do
      visit new_organisation_upload_path(organisation, configuration_id: configuration.id)

      attach_file("file-upload", Rails.root.join("spec/fixtures/fichier_allocataire_test.xlsx"))

      expect(page).to have_button "Rouvrir le dossier"
      expect(page).to have_content "Dossier archivé"
      expect(page).to have_content "CDI"

      expect(page).not_to have_button "Inviter par SMS"

      click_button "Rouvrir le dossier"

      expect(page).to have_content "Dossier de l'allocataire rouvert avec succès"
      click_button "OK"

      expect(page).to have_button "Inviter par SMS"
    end

    context "when the archive is in another department" do
      let!(:archive) do
        create(:archive, applicant: applicant, department: create(:department))
      end

      it "does not show the applicant as archived" do
        visit new_organisation_upload_path(organisation, configuration_id: configuration.id)

        attach_file("file-upload", Rails.root.join("spec/fixtures/fichier_allocataire_test.xlsx"))

        expect(page).to have_button "Inviter par SMS"

        expect(page).not_to have_button "Rouvrir le dossier"
        expect(page).not_to have_content "Dossier archivé"
      end
    end
  end
end
