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
  end

  it "signs out the agent when clicking a turbo link" do
    click_link "Ajouter un usager"

    expect(page).to have_current_path(/rdv-solidarites-test/, url: true, wait: 10)
  end

  it "signs out the agent when a link is prefetched on hover" do
    find("a", text: "Ajouter un usager").hover

    expect(page).to have_current_path(/rdv-solidarites-test/, url: true, wait: 10)
  end

  it "signs out the agent when submitting a turbo form" do
    click_button "Rechercher"

    expect(page).to have_current_path(/rdv-solidarites-test/, url: true, wait: 10)
  end
end
