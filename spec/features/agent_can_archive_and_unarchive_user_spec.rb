describe "Agents can archive and unarchive user", :js do
  let!(:agent) { create(:agent, organisations: [organisation]) }
  let!(:department) { create(:department) }
  let!(:organisation) { create(:organisation, department:) }
  let!(:user) { create(:user, organisations: [organisation]) }

  before { setup_agent_session(agent) }

  describe "from show page" do
    it "can archive and unarchive the user" do
      visit organisation_user_path(organisation, user)
      expect(page).to have_link("Archiver le dossier")

      click_link("Archiver le dossier")

      expect(page).to have_content("Le dossier sera archivé dans l'organisation")
      fill_in "archive_archiving_reason", with: "déménagement"

      click_button "Archiver"

      expect(page).to have_content "Dossier archivé"
      expect(page).to have_content "Cet usager est archivé sur l'organisation #{organisation.name}"

      expect(Archive.count).to eq(1)
      expect(Archive.first.user).to eq(user)
      expect(Archive.first.archiving_reason).to eq("déménagement")

      expect(page).to have_link "Rouvrir le dossier"
      click_link "Rouvrir le dossier"

      within ".modal.show" do
        expect(page).to have_content "Êtes vous sûr ?"
        expect(page).to have_content "Le dossier de #{user} sera rouvert dans l'organisation #{organisation.name}"
        click_button "Rouvrir le dossier"
      end

      expect(page).to have_no_content "Dossier archivé"

      expect(page).to have_content("Archiver le dossier")

      expect(Archive.count).to eq(0)
    end

    context "department level" do
      let!(:other_org) { create(:organisation, department: department, users: [user]) }
      let!(:agent) { create(:agent, organisations: [organisation, other_org]) }
      let!(:archive) { create(:archive, user: user, organisation: other_org) }

      it "can archive a user" do
        visit department_user_path(department, user)
        expect(page).to have_link("Archiver le dossier")

        click_link("Archiver le dossier")

        expect(page).to have_content("Archives existantes")
        expect(page).to have_content(other_org.name)
        fill_in "archives[archiving_reason]", with: "déménagement"
        check("archives[organisation_ids][]", match: :first)

        click_button "Archiver"

        expect(page).to have_content "Dossier archivé"
        expect(page).to have_content "Cet usager est archivé sur les organisations Organisation n°"

        expect(Archive.count).to eq(2)
      end

      context "no organisation selected" do
        it "prevents archiving" do
          visit department_user_path(department, user)
          expect(page).to have_link("Archiver le dossier")

          click_link("Archiver le dossier")

          expect(page).to have_content("Archives existantes")
          expect(page).to have_content(other_org.name)
          fill_in "archives[archiving_reason]", with: "déménagement"

          click_button "Archiver"

          expect(page).to have_content "La sélection d'une organisation est nécessaire"
        end
      end
    end

    context "when the user is archived in another organisation" do
      let!(:other_org) { create(:organisation, department: department, users: [user]) }
      let!(:archive) { create(:archive, user: user, organisation: other_org) }

      it "can still archive in other org" do
        visit organisation_user_path(organisation, user)
        expect(page).to have_link("Archiver le dossier")

        click_link("Archiver le dossier")

        expect(page).to have_content("Le dossier sera archivé dans l'organisation")
        fill_in "archive_archiving_reason", with: "déménagement"

        click_button "Archiver"

        expect(page).to have_content "Dossier archivé"
        expect(page).to have_content "Cet usager est archivé sur les organisations Organisation n°"

        expect(Archive.count).to eq(2)

        expect(page).to have_link "Rouvrir le dossier"
        click_link "Rouvrir le dossier"

        within ".modal.show" do
          expect(page).to have_content "Êtes vous sûr ?"
          expect(page).to have_content "Le dossier de #{user} sera rouvert dans l'organisation #{organisation.name}"
          click_button "Rouvrir le dossier"
        end

        expect(page).to have_no_content "Dossier archivé"
        expect(page).to have_no_content "Motif d'archivage"
        expect(page).to have_no_content "déménagement"

        expect(page).to have_content("Archiver le dossier")

        expect(Archive.count).to eq(1)
      end
    end
  end
end
