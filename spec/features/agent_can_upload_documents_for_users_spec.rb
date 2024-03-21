describe "Agents can upload documents for users", :js do
  let!(:agent) { create(:agent) }
  let!(:department) { create(:department, number: "26") }
  let!(:organisation) do
    create(:organisation, name: "CD 26", agents: organisation_agents, department: department)
  end
  let!(:user) do
    create(:user, organisations: [organisation, other_organisation])
  end
  let!(:organisation_agents) do
    [agent, create(:agent, first_name: "Kad", last_name: "Merad"),
     create(:agent, first_name: "Olivier", last_name: "Barroux")]
  end

  let!(:other_organisation) do
    create(:organisation, name: "Asso 26", agents: other_organisation_agents, department:)
  end

  let!(:other_organisation_agents) { [create(:agent, first_name: "Jean-Paul", last_name: "Rouve")] }

  before { setup_agent_session(agent) }

  context "when on a user profile" do
    it "can upload a file" do
      visit organisation_user_path(organisation_id: organisation.id, id: user.id)
      expect(page).to have_content("Parcours")

      click_link("Parcours")

      expect(page).to have_content("Aucun diagnostic renseigné.")

      # Making sure the file is not uploaded if the format is not correct
      find_by_id("file-input-diagnostic", visible: false).set(Rails.root.join("spec/fixtures/fichier_contact_test.csv"))

      expect(page).to have_content("Seuls les formats PDF")
      expect(page).to have_content("Aucun diagnostic renseigné.")

      find_by_id("file-input-diagnostic", visible: false).set(Rails.root.join("spec/fixtures/dummy.pdf"))

      expect(page).to have_no_content("Aucun diagnostic renseigné.")
      expect(page).to have_content("dummy.pdf")
      expect(page).to have_css(".document-link", count: 1)
      expect(user.diagnostics.first.file.filename).to eq("dummy.pdf")

      find_by_id("file-input-contract", visible: false).set(Rails.root.join("spec/fixtures/dummy.pdf"))

      expect(page).to have_no_content("Aucun contrat renseigné.")
      expect(page).to have_content("dummy.pdf")
      expect(page).to have_css(".document-link", count: 2)
      expect(user.contracts.first.file.filename).to eq("dummy.pdf")

      # Other agents can see the files
      setup_agent_session(other_organisation_agents.first)
      visit organisation_user_path(organisation_id: other_organisation.id, id: user.id)
      click_link("Parcours")

      expect(page).to have_css(".document-link", count: 2)

      # Only the agent who uploaded the file can delete it
      expect(page).to have_no_css("#delete-button-#{user.contracts.first.id}")

      # Back to the first agent
      setup_agent_session(agent)

      visit organisation_user_path(organisation_id: organisation.id, id: user.id)
      click_link("Parcours")

      accept_alert do
        find_by_id("delete-button-#{user.contracts.first.id}").click
      end

      accept_alert do
        find_by_id("delete-button-#{user.diagnostics.first.id}").click
      end

      expect(page).to have_no_css(".document-link")

      expect(user.contracts.count).to eq(0)
      expect(user.diagnostics.count).to eq(0)
    end

    context "when a document has been uploaded" do
      let!(:document) { create(:parcours_document, user:, agent:, type: "Diagnostic") }

      it "can update the date" do
        visit organisation_user_path(organisation_id: organisation.id, id: user.id)
        expect(page).to have_content("Parcours")

        click_link("Parcours")
        find(".edit-date-button").click
        fill_in("parcours_document_document_date", with: Time.zone.local(2024, 3, 20))
        find(".validate-date-button").click
        expect(find(".document-date-value")).to have_content("20/03/2024")
        expect(document.reload.document_date).to eq(Time.zone.parse("2024-03-20"))
      end

      context "agent is not the owner" do
        let!(:document) do
          create(:parcours_document, user:, agent: other_organisation_agents.first, type: "Diagnostic")
        end

        it "cannot update the date" do
          visit organisation_user_path(organisation_id: organisation.id, id: user.id)
          expect(page).to have_content("Parcours")

          click_link("Parcours")
          expect(page).to have_no_css(".edit-date-button")
        end
      end
    end
  end
end
