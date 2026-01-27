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

  context "when accessing the parcours url manually" do
    before do
      visit organisation_user_path(organisation_id: organisation.id, id: user.id)
    end

    context "on an organisation that is not authorized to see the parcours" do
      let!(:organisation) do
        create(:organisation, organisation_type: "siae", name: "CD 26", agents: organisation_agents,
                              department: department)
      end

      it "redirects right away" do
        visit department_user_parcours_path(user_id: user.id, department_id: department.id)
        expect(page).to have_current_path(department_users_path(department))
      end
    end

    context "on a department that is not authorized to see the parcours" do
      let!(:department) { create(:department, number: "75", parcours_enabled: false) }

      it "redirects right away" do
        visit department_user_parcours_path(user_id: user.id, department_id: department.id)
        expect(page).to have_current_path(department_users_path(department))
      end
    end

    it "renders the page" do
      visit department_user_parcours_path(user_id: user.id, department_id: department.id)
      expect(page).to have_content("Aucun diagnostic renseigné.")
    end
  end

  context "when on a user page" do
    context "on an organisation that is not authorized to see the parcours" do
      let!(:organisation) do
        create(:organisation, organisation_type: "siae", name: "CD 26", agents: organisation_agents,
                              department: department)
      end

      it "cannot see the parcours tab" do
        visit organisation_user_path(organisation_id: organisation.id, id: user.id)

        expect(page).to have_content(user.last_name.upcase)
        expect(page).to have_no_content("Parcours")
      end
    end

    context "on a department that is not authorized to see the parcours" do
      let!(:department) { create(:department, number: "75", parcours_enabled: false) }

      it "cannot see the parcours tab" do
        visit organisation_user_path(organisation_id: organisation.id, id: user.id)

        expect(page).to have_content(user.last_name.upcase)
        expect(page).to have_no_content("Parcours")
      end
    end

    context "on a user that only belongs to organisations without parcours access" do
      let!(:organisation) do
        create(:organisation, organisation_type: "siae", name: "Asso1", agents: organisation_agents,
                              department: department)
      end

      let(:other_organisation) do
        create(:organisation, organisation_type: "siae", name: "Asso2", agents: organisation_agents,
                              department: department)
      end

      # User doesn't belong to this org, but agent does
      let!(:yet_another_organisation) do
        create(:organisation, organisation_type: "france_travail", name: "FT", agents: organisation_agents,
                              department: department)
      end

      let(:department) { create(:department, number: "26", parcours_enabled: true) }

      it "cannot see the parcours tab" do
        visit department_user_path(id: user.id, department_id: department.id)

        expect(page).to have_content(user.last_name.upcase)
        expect(page).to have_no_content("Parcours")
      end

      it "cannot access parcours tab manually" do
        visit department_user_parcours_path(user_id: user.id, department_id: department.id)
        expect(page).to have_content("Votre compte ne vous permet pas d'effectuer cette action")
      end
    end

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

      find_by_id("delete-button-#{user.contracts.first.id}").click
      confirm_modal

      expect(page).to have_no_css(".modal.show")
      sleep 0.3
      find_by_id("delete-button-#{user.diagnostics.first.id}").click
      sleep 0.3
      confirm_modal

      expect(page).to have_no_css(".document-link")

      expect(user.contracts.count).to eq(0)
      expect(user.diagnostics.count).to eq(0)
    end

    context "when a document has been uploaded" do
      let!(:document) { create(:parcours_document, user:, agent:, type: "Diagnostic", department:) }

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
          create(:parcours_document, user:, department:, agent: other_organisation_agents.first, type: "Diagnostic")
        end

        it "cannot update the date" do
          visit organisation_user_path(organisation_id: organisation.id, id: user.id)
          expect(page).to have_content("Parcours")

          click_link("Parcours")
          expect(page).to have_no_css(".edit-date-button")
        end

        context "when the agent is an admin in the org" do
          before do
            agent.agent_roles.find { it.organisation_id == organisation.id }.update!(access_level: "admin")
          end

          it "can edit the document" do
            visit organisation_user_path(organisation_id: organisation.id, id: user.id)
            expect(page).to have_content("Parcours")

            click_link("Parcours")
            expect(page).to have_css(".edit-date-button")
          end
        end
      end
    end

    context "when user has multiple documents in multiple departments" do
      let!(:other_department) { create(:department) }
      let!(:other_department_agent) { create(:agent) }
      let!(:other_department_organisation) do
        create(:organisation, department: other_department, users: [user], agents: [other_department_agent])
      end
      let!(:first_department_diagnostic) do
        create(:parcours_document, user:, document_date: "20/12/1995", type: "Diagnostic", department:)
      end
      let!(:second_department_orientation) do
        create(:parcours_document, user:, document_date: "10/11/2002", type: "Contract", department: other_department)
      end

      it "shows the department document only" do
        visit department_user_parcours_path(user_id: user.id, department_id: department.id)

        expect(page).to have_content("20/12/1995")
        expect(page).to have_no_content("10/11/2002")
        expect(page).to have_content("Aucun contrat renseigné")
      end
    end
  end
end
