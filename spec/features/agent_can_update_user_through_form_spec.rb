describe "Agents can update user through form", :js do
  let!(:agent) { create(:agent, organisations: [organisation]) }
  let!(:department) { create(:department) }
  let!(:organisation) do
    create(
      :organisation,
      department: department,
      rdv_solidarites_organisation_id: rdv_solidarites_organisation_id,
      # needed for the organisation users page
      category_configurations: [category_configuration],
      slug: "org1"
    )
  end

  let!(:category_configuration) do
    create(:category_configuration)
  end

  let!(:user) do
    create(
      :user,
      first_name: "Milla", last_name: "Jovovich", rdv_solidarites_user_id: rdv_solidarites_user_id,
      organisations: [organisation]
    )
  end

  let!(:affiliation_number) { "122334455" }
  let!(:role) { "demandeur" }
  let!(:department_internal_id) { "030303" }
  let!(:email) { "milla@jovovich.com" }
  let!(:phone_number) { "0782605941" }

  let!(:rdv_solidarites_user_id) { 2323 }
  let!(:rdv_solidarites_organisation_id) { 3234 }

  describe "#update" do
    before do
      setup_agent_session(agent)
      stub_rdv_solidarites_update_user_and_associations(rdv_solidarites_user_id)
      # Somehow the tests fail on CI if we do not put this line, the before_save :set_status callback is not
      # triggered on the follow-ups when we create them (in Users::Save) and so there is an error when redirected
      # to show page after update
      allow_any_instance_of(FollowUp).to receive(:status).and_return("not_invited")
    end

    it "can update the user" do
      visit edit_organisation_user_path(organisation, user)

      page.fill_in "user_first_name", with: "Milo"
      click_button "Enregistrer"

      expect(page).to have_current_path(organisation_user_path(organisation, user))
      expect(page).to have_no_content("Milla")
      expect(page).to have_content("Milo")
      expect(user.reload.first_name).to eq("Milo")
    end

    context "it shows different attributes depending on organisation type" do
      context "for a conseil departemental" do
        before { organisation.update! organisation_type: "conseil_departemental" }

        it "shows all the attributes" do
          visit organisation_user_path(organisation, user)

          expect(page).to have_content("Numéro de sécurité sociale")
          expect(page).to have_content("ID interne au département")

          click_button "Modifier"

          expect(page).to have_content("Numéro de sécurité sociale")
          expect(page).to have_content("ID interne au département")
        end
      end

      context "for an siae" do
        before { organisation.update! organisation_type: "siae" }

        it "does not show nir and department_internal_idd" do
          visit organisation_user_path(organisation, user)

          expect(page).to have_button("Modifier")
          expect(page).to have_no_content("Numéro de sécurité sociale")
          expect(page).to have_no_content("ID interne au département")

          click_button "Modifier"

          expect(page).to have_no_content("Numéro de sécurité sociale")
          expect(page).to have_no_content("ID interne au département")
        end
      end

      context "for delegataire rsa" do
        before { organisation.update! organisation_type: "delegataire_rsa" }

        it "does not show nir and department_internal_idd" do
          visit organisation_user_path(organisation, user)

          expect(page).to have_content("ID interne au département")
          expect(page).to have_no_content("Numéro de sécurité sociale")

          click_button "Modifier"

          expect(page).to have_no_content("Numéro de sécurité sociale")
          expect(page).to have_content("ID interne au département")
        end
      end

      context "on department page" do
        let!(:organisation2) { create(:organisation, department:, agents: [agent], users: [user]) }

        before do
          organisation.update! organisation_type: "delegataire_rsa"
          organisation2.update! organisation_type: "siae"
        end

        it "shows the informations from the organisation that has the most privileges" do
          visit department_user_path(department, user)

          expect(page).to have_content("ID interne au département")
          expect(page).to have_no_content("Numéro de sécurité sociale")

          click_button "Modifier"

          expect(page).to have_no_content("Numéro de sécurité sociale")
          expect(page).to have_content("ID interne au département")
        end
      end
    end
  end
end
