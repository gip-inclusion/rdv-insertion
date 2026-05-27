describe "Agent single session enforcement", :js do
  let!(:organisation) { create(:organisation) }
  let!(:agent) { create(:agent, organisations: [organisation]) }

  before do
    setup_agent_session(agent)
    visit organisation_users_path(organisation)
    agent.generate_session_key!
  end

  it "signs out the agent on the next navigate request" do
    page.execute_script("window.location.href = '#{organisation_users_path(organisation)}'")

    expect(page).to have_current_path(/rdv-solidarites-test/, url: true, wait: 10)
    expect(page.get_rack_session["agent_auth"]).to be_nil
  end

  it "signs out the agent when clicking a turbo link" do
    click_link "Ajouter un usager"

    expect(page).to have_current_path(/rdv-solidarites-test/, url: true, wait: 10)
    expect(page.get_rack_session["agent_auth"]).to be_nil
  end

  it "signs out the agent when a link is prefetched on hover" do
    find("a", text: "Ajouter un usager").hover

    expect(page).to have_current_path(/rdv-solidarites-test/, url: true, wait: 10)
    expect(page.get_rack_session["agent_auth"]).to be_nil
  end

  it "signs out the agent when submitting a turbo form" do
    click_button "Rechercher"

    expect(page).to have_current_path(/rdv-solidarites-test/, url: true, wait: 10)
    expect(page.get_rack_session["agent_auth"]).to be_nil
  end

  context "during impersonation" do
    let!(:super_admin) { create(:agent, :super_admin_verified, organisations: [organisation]) }

    before do
      timestamp = Time.zone.now.to_i
      page.set_rack_session(agent_auth: {
                              id: agent.id,
                              origin: "impersonate",
                              created_at: timestamp,
                              signature: agent.sign_with(timestamp),
                              session_key: agent.session_key,
                              super_admin_auth: agent_auth_hash_from_sign_in_form(super_admin)
                            })
      visit organisation_users_path(organisation)
    end

    it "signs out the impersonator when the impersonated agent logs in again" do
      agent.generate_session_key!
      page.execute_script("window.location.href = '#{organisation_users_path(organisation)}'")

      expect(page).to have_current_path(/rdv-solidarites-test/, url: true, wait: 10)
      expect(page.get_rack_session["agent_auth"]).to be_nil
      expect(super_admin.reload.last_super_admin_authentication_request.invalidated_at).to be_present
    end

    it "signs out the impersonator when the super admin logs in again" do
      super_admin.generate_session_key!
      page.execute_script("window.location.href = '#{organisation_users_path(organisation)}'")

      expect(page).to have_current_path(/rdv-solidarites-test/, url: true, wait: 10)
      expect(page.get_rack_session["agent_auth"]).to be_nil
      expect(super_admin.reload.last_super_admin_authentication_request.invalidated_at).to be_present
    end
  end
end
