describe "Admins can authorize basic agents to export csvs", :js do
  let!(:department) { create(:department) }
  let!(:organisation) { create(:organisation, department:) }
  let!(:organisation2) { create(:organisation, department:) }
  let!(:other_department) { create(:department) }
  let!(:other_organisation) { create(:organisation, department: other_department) }

  let!(:admin) { create(:agent, admin_role_in_organisations: [organisation, organisation2, other_organisation]) }
  let!(:basic_agent) { create(:agent, basic_role_in_organisations: [organisation, organisation2, other_organisation]) }
  let!(:agent_role_for_organisation) { organisation.agent_roles.find { |ar| ar.agent_id == basic_agent.id } }

  before do
    setup_agent_session(admin)
  end

  context "from configure organisation page" do
    before do
      visit organisation_category_configurations_path(organisation)
      click_link("Gérer les autorisations", href: organisation_csv_export_authorizations_path(organisation))
    end

    it "displays the export authorizations of basic agents" do
      expect(page).to have_field(
        "csv_export_authorizations_agent_role_ids_#{agent_role_for_organisation.id}", checked: false
      )
      expect(page).to have_content(basic_agent.email)
      expect(page).to have_content(basic_agent.to_s)
      expect(all('input[type="checkbox"]').size).to eq(1)
    end

    it "can toggle authorization to export csvs for basic agents" do
      find(:css, "#csv_export_authorizations_agent_role_ids_#{agent_role_for_organisation.id}").click
      click_button("Confirmer")

      click_link("Gérer les autorisations", href: organisation_csv_export_authorizations_path(organisation))
      expect(page).to have_field(
        "csv_export_authorizations_agent_role_ids_#{agent_role_for_organisation.id}", checked: true
      )
      basic_agent.reload.agent_roles.where(organisation: department.organisations)
      agent_roles_for_organisation = basic_agent.reload.agent_roles.where(organisation: organisation)
      agent_roles_for_other_organisations = basic_agent.reload.agent_roles.where.not(organisation: organisation)
      expect(agent_roles_for_organisation).to all(have_attributes(authorized_to_export_csv: true))
      expect(agent_roles_for_other_organisations).to all(have_attributes(authorized_to_export_csv: false))

      find(:css, "#csv_export_authorizations_agent_role_ids_#{agent_role_for_organisation.id}").click
      click_button("Confirmer")

      click_link("Gérer les autorisations", href: organisation_csv_export_authorizations_path(organisation))
      expect(page).to have_field(
        "csv_export_authorizations_agent_role_ids_#{agent_role_for_organisation.id}", checked: false
      )
      expect(basic_agent.reload.agent_roles).to all(have_attributes(authorized_to_export_csv: false))

      expect(page).to have_current_path(organisation_configuration_path(organisation))
    end
  end

  context "authorization checks" do
    context "when agent is not admin of the organisation" do
      let!(:non_admin_agent) { create(:agent, basic_role_in_organisations: [organisation]) }

      before do
        setup_agent_session(non_admin_agent)
      end

      it "prevents access to the csv export authorizations page" do
        visit organisation_csv_export_authorizations_path(organisation)

        expect(page).to have_content("Vous n'êtes pas autorisé")
        expect(page).to have_current_path(root_path)
      end

      it "prevents submitting the batch_update form" do
        # Attempting to directly POST to the endpoint
        page.driver.post(
          batch_update_organisation_csv_export_authorizations_path(organisation),
          csv_export_authorizations: {
            organisation_id: organisation.id,
            agent_role_ids: [agent_role_for_organisation.id]
          }
        )

        expect(agent_role_for_organisation.reload.authorized_to_export_csv).to be false
      end
    end

    context "when trying to authorize agent roles from other organisations" do
      let!(:agent_role_from_other_org) do
        other_organisation.agent_roles.find { |ar| ar.agent_id == basic_agent.id }
      end

      before do
        visit organisation_category_configurations_path(organisation)
        click_link("Gérer les autorisations", href: organisation_csv_export_authorizations_path(organisation))
      end

      it "only shows agent roles from the current organisation" do
        expect(page).to have_field(
          "csv_export_authorizations_agent_role_ids_#{agent_role_for_organisation.id}",
          visible: :all
        )
        expect(page).to have_no_field(
          "csv_export_authorizations_agent_role_ids_#{agent_role_from_other_org.id}",
          visible: :all
        )
      end

      it "prevents authorizing agent roles from other organisations via direct form submission" do
        # Simulate a malicious actor submitting agent_role_ids from other organisations
        page.driver.post(
          batch_update_organisation_csv_export_authorizations_path(organisation),
          csv_export_authorizations: {
            organisation_id: organisation.id,
            agent_role_ids: [agent_role_from_other_org.id]
          }
        )

        expect(agent_role_from_other_org.reload.authorized_to_export_csv).to be false
        expect(agent_role_for_organisation.reload.authorized_to_export_csv).to be false
      end

      it "only processes agent roles that belong to the organisation" do
        # Mix of valid and invalid agent role IDs
        page.driver.post(
          batch_update_organisation_csv_export_authorizations_path(organisation),
          csv_export_authorizations: {
            organisation_id: organisation.id,
            agent_role_ids: [agent_role_for_organisation.id, agent_role_from_other_org.id]
          }
        )

        expect(agent_role_for_organisation.reload.authorized_to_export_csv).to be true
        expect(agent_role_from_other_org.reload.authorized_to_export_csv).to be false
      end
    end
  end
end
