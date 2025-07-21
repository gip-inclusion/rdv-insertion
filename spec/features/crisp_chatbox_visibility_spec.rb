describe "Crisp chatbox visibility", :js do
  let!(:organisation) { create(:organisation) }
  let!(:agent) do
    create(:agent, organisations: [organisation], cookies_consent: create(:cookies_consent, support_accepted: true))
  end

  context "when user is not logged in" do
    it "does not display the crisp chatbox" do
      visit root_path
      expect(page).to have_css('div[data-controller="crisp"][data-crisp-display-crisp-value="false"]')
      expect(page).to have_no_css('script[src="https://client.crisp.chat/l.js"]', visible: :hidden)
    end
  end

  context "when agent is logged in" do
    before do
      ENV["ENABLE_CRISP"] = "true"
      setup_agent_session(agent)
    end

    it "displays the crisp chatbox" do
      visit organisation_users_path(organisation)
      expect(page).to have_css('div[data-controller="crisp"][data-crisp-display-crisp-value="true"]')
      expect(page).to have_css('script[src="https://client.crisp.chat/l.js"]', visible: :hidden)
    end
  end

  context "when agent is logged in but ENABLE_CRISP is false" do
    before do
      ENV["ENABLE_CRISP"] = "false"
      setup_agent_session(agent)
    end

    it "does not display the crisp chatbox" do
      visit organisation_users_path(organisation)
      expect(page).to have_css('div[data-controller="crisp"][data-crisp-display-crisp-value="false"]')
      expect(page).to have_no_css('script[src="https://client.crisp.chat/l.js"]', visible: :hidden)
    end
  end

  context "when agent is logged in but support not accepted" do
    before do
      agent.cookies_consent.update!(support_accepted: false)
      setup_agent_session(agent)
    end

    it "does not display the crisp chatbox" do
      visit organisation_users_path(organisation)
      expect(page).to have_css('div[data-controller="crisp"][data-crisp-display-crisp-value="false"]')
    end
  end
end
