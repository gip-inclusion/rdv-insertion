describe "Super admin can log in as another agent", :js do
  let!(:super_admin_department) { create(:department) }
  let!(:super_admin_organisation1) { create(:organisation, department: super_admin_department) }
  let!(:super_admin_organisation2) { create(:organisation, department: super_admin_department) }
  let!(:super_admin) do
    create(:agent, :super_admin_verified, organisations: [super_admin_organisation1, super_admin_organisation2])
  end
  let!(:agent_department) { create(:department) }
  let!(:agent_organisation1) { create(:organisation, department: agent_department) }
  let!(:agent_organisation2) { create(:organisation, department: agent_department) }
  let!(:agent) { create(:agent, organisations: [agent_organisation1, agent_organisation2]) }

  before do
    setup_agent_session(super_admin)
  end

  context "when agent is super_admin" do
    it "can log in as another agent" do
      visit super_admins_root_path
      expect(page).to have_content(agent.last_name)
      expect(page).to have_content(super_admin.last_name)
      click_link(agent.last_name)

      expect(page).to have_button("Se logger en tant que", wait: 10)
      click_button("Se logger en tant que")

      # Verify that the super admin is now logged in as the agent
      expect(page).to have_content(
        "Vous êtes connecté.e en tant que #{agent.first_name} #{agent.last_name.upcase}", wait: 10
      )
      expect(page).to have_current_path(organisations_path)
      # We check the organisations displayed to check that it is really the agent's account
      expect(page).to have_content(agent_department.name)
      expect(page).to have_content(agent_organisation1.name)
      expect(page).to have_content(agent_organisation2.name)
      expect(page).to have_no_content(super_admin_department.name)
      expect(page).to have_no_content(super_admin_organisation1.name)
      expect(page).to have_no_content(super_admin_organisation2.name)

      # Verify that the super admin can switch back to its account by clicking on the Super admin button
      expect(page).to have_link("Revenir à ma session",
                                href: super_admins_agent_impersonation_path(agent_id: agent.id))
      click_link("Revenir à ma session")
      expect(page).to have_current_path(organisations_path, wait: 10)

      # Verify it's really the super admin account by checking the organisations displayed
      expect(page).to have_content(super_admin_department.name)
      expect(page).to have_content(super_admin_organisation1.name)
      expect(page).to have_content(super_admin_organisation2.name)
      expect(page).to have_no_content(agent_department.name)
      expect(page).to have_no_content(agent_organisation1.name)
      expect(page).to have_no_content(agent_organisation2.name)
    end

    it "cannot impersonate himself" do
      visit super_admins_agent_path(super_admin.id)
      expect(page).to have_content(super_admin.first_name)
      expect(page).to have_content(super_admin.last_name)
      expect(page).to have_no_content("Se logger en tant que")
    end

    context "when the agent impersonated is a super_admin" do
      let!(:agent) { create(:agent, :super_admin_verified, organisations: [agent_organisation1, agent_organisation2]) }
      let!(:other_agent) { create(:agent) }

      it "cannot impersonate while impersonating" do
        visit super_admins_agent_path(agent.id)
        click_button("Se logger en tant que")

        expect(page).to have_content(
          "Vous êtes connecté.e en tant que #{agent.first_name} #{agent.last_name.upcase}", wait: 10
        )
        expect(page).to have_current_path(organisations_path)

        visit super_admins_agent_path(other_agent.id)

        expect(page).to have_button("Se logger en tant que", wait: 10)
        click_button("Se logger en tant que")
        # it disconnects the agent
        expect(page).to have_current_path(root_path)
      end
    end
  end

  context "when the agent is not a super admin" do
    let!(:not_super_admin) { create(:agent, super_admin: false) }

    before do
      setup_agent_session(not_super_admin)
    end

    it "can log in as another agent" do
      visit super_admins_agent_path(agent.id)

      expect(page).to have_current_path(organisations_path)
      expect(page).to have_no_content("Se logger en tant que")
    end
  end
end
